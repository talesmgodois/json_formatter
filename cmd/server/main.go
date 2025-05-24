package main

import (
	"embed"
	"fmt"
	"html/template"
	"io/fs"
	"log"
	"net/http"
	"os"
)

var (
	//go:embed assets
	static embed.FS
	pages  = map[string]string{
		"/": "static/index.html",
	}
)

func main() {

	port := os.Getenv("PORT")
	fmt.Printf("PORT=%v", port)
	if port == "" {
		port = "9090"
	}
	// // httpServeTemplates()
	// http.FileServer(http.Dir("static"))
	// err := http.ListenAndServe(fmt.Sprintf(":%s", port), nil)

	fSys, err := fs.Sub(static, "assets")
	if err != nil {
		fmt.Printf("Can't load server %v", err.Error())
		return
	}
	err = http.ListenAndServe(fmt.Sprintf(":%v", port), http.FileServer(http.FS(fSys)))
	if err != nil {
		fmt.Println("Failed to start server", err)
		return
	} else {
		fmt.Printf("Server started at port %s\n", port)
	}
}

func httpServeTemplates() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		page, ok := pages[r.URL.Path]
		if !ok {
			w.WriteHeader(http.StatusNotFound)
			return
		}
		tpl, err := template.ParseFS(static, page)
		if err != nil {
			log.Printf("page %s not found in pages cache...", r.RequestURI)
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		w.Header().Set("Content-Type", "text/html")
		w.WriteHeader(http.StatusOK)
		data := map[string]interface{}{
			"userAgent": r.UserAgent(),
		}
		if err := tpl.Execute(w, data); err != nil {
			return
		}
	})
}
