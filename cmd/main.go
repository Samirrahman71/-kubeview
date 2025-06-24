package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // Because 8080 is the best port, fight me
	}

	// Set up our incredibly sophisticated routes
	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/health", healthHandler)
	http.Handle("/metrics", promhttp.Handler()) // For when you want fancy graphs

	log.Printf(" kubeview starting up on port %s (because someone has to)", port)
	log.Printf(" Pro tip: hit /health to make sure I'm not dead")
	
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf(" Server crashed and burned: %v", err)
	}
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	timestamp := time.Now().Format(time.RFC3339)
	log.Printf(" Someone visited home at %s from %s", timestamp, r.RemoteAddr)
	
	w.Header().Set("Content-Type", "text/plain")
	fmt.Fprintf(w, "Hello from kubeview! \n\nI'm alive and kicking at %s\n\n(This message was brought to you by too much coffee and mild frustration)", timestamp)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	timestamp := time.Now().Format(time.RFC3339)
	log.Printf(" Health check at %s from %s (yes, I'm still alive)", timestamp, r.RemoteAddr)
	
	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "OK - Still breathing at %s", timestamp)
}
