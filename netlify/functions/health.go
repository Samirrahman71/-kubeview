package main

import (
	"context"
	"fmt"
	"time"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	timestamp := time.Now().Format(time.RFC3339)
	
	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Headers: map[string]string{
			"Content-Type": "text/plain",
			"Access-Control-Allow-Origin": "*",
		},
		Body: fmt.Sprintf("OK - Still breathing at %s (my first go deployment lololol)", timestamp),
	}, nil
}

func main() {
	lambda.Start(handler)
}
