package main

import (
	"context"
	"fmt"
	"os"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sns"
)

const (
	removedString = "Removed"
	createdString = "Created"
)

func determineParticiple(eventName string) (participle string) {
	if strings.Contains(eventName, removedString) {
		participle = "removed"
	}
	if strings.Contains(eventName, createdString) {
		participle = "created"
	}
	return
}

func mustConfig(ctx context.Context) aws.Config {
	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		panic(err)
	}
	return cfg
}

func mustRecord(e events.S3Event) events.S3EventRecord {
	if len(e.Records) != 1 {
		panic("function supports only a single event record")
	}
	return e.Records[0]
}

type notification struct {
	subject, message string
}

func newNotificationFrom(record events.S3EventRecord) notification {
	bucket, object := record.S3.Bucket, record.S3.Object

	participle := determineParticiple(record.EventName)
	subject := fmt.Sprintf("File was %s in bucket %q", participle, bucket.Name)
	msg := fmt.Sprintf("A file was %s in bucket %q: %s (%vB)", participle, bucket.Name, object.Key, object.Size)

	return notification{subject, msg}
}

func (n notification) publish(ctx context.Context, c *sns.Client) {
	_, err := c.Publish(ctx, &sns.PublishInput{
		Subject:  aws.String(n.subject),
		Message:  aws.String(n.message),
		TopicArn: aws.String(os.Getenv("S3TOPIC")),
	})

	if err != nil {
		panic(err)
	}
}

func handler(ctx context.Context, s3Event events.S3Event) {
	record := mustRecord(s3Event)
	client := sns.NewFromConfig(mustConfig(ctx))

	notification := newNotificationFrom(record)
	fmt.Printf("preparing to send notification with subject %q\n", notification.subject)
	notification.publish(ctx, client)
	fmt.Println("successfully sent message")
}

func main() {
	lambda.Start(handler)
}
