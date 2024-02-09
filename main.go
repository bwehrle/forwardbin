package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"strconv"
	"strings"
)

func main() {
	portPtr := flag.Int("p", 80, "port number to listen on")
	flag.Parse()
	http.HandleFunc("/health/ready", getIsReady)
	http.HandleFunc("/status/", getStatus)
	http.HandleFunc("/get/", getUrlHandler)

	err := http.ListenAndServe(":"+strconv.Itoa(*portPtr), nil)
	fmt.Print(fmt.Errorf("quitting with error %w", err))
}

func getStatus(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("GET request: %s\n", r.URL)
	for key := range r.Header {
		fmt.Printf("Header: %s: %s\n", key, r.Header.Get(key))
	}
	pathParts := strings.Split(r.URL.Path, "/")
	if len(pathParts) == 3 {
		if i, err := strconv.Atoi(pathParts[1]); err == nil && i != 200 {
			w.WriteHeader(i)
		}
	} else {
		w.Write([]byte("Request not valid"))
		w.WriteHeader(400)
	}
}

func getIsReady(w http.ResponseWriter, r *http.Request) {
}

func getUrlHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("GET request: %s\n", r.URL)
	for key := range r.Header {
		fmt.Printf("Header: %s: %s\n", key, r.Header.Get(key))
	}
	pathParts := strings.Split(r.URL.Path, "/")
	if len(pathParts) >= 3 {
		// turn the url parts into http://server/path
		getUrl := fmt.Sprintf("http://%s", strings.Join(pathParts[2:], "/"))
		log.Printf("Sending GET request to : %s", getUrl)
		resp, err := http.Get(getUrl)
		if err != nil {
			log.Printf("Failed to send request: %v", err)
			w.WriteHeader(500)
		} else {
			defer resp.Body.Close()
			body, err := io.ReadAll(resp.Body)
			if err != nil {
				log.Printf("Failed to read response body: %v", err)
				w.WriteHeader(400)
			} else {
				w.Write(body)
			}
		}
	}
}
