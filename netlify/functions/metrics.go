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
	
	metrics := fmt.Sprintf(`# HELP kubeview_requests_total Total number of requests
# TYPE kubeview_requests_total counter
kubeview_requests_total 42

# HELP kubeview_uptime_seconds Server uptime in seconds  
# TYPE kubeview_uptime_seconds gauge
kubeview_uptime_seconds 3600

# Generated at %s
# This is my first go deployment lololol`, timestamp)
	
	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Headers: map[string]string{
			"Content-Type": "text/plain",
			"Access-Control-Allow-Origin": "*",
		},
		Body: metrics,
	}, nil
}

func main() {
	lambda.Start(handler)
}
