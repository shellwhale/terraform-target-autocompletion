package main

import (
	"fmt"
	"os"

	"github.com/shellwhale/terraform-target-autocompletion/internal/completion"
)

func main() {
	var searchString string = ""
	if len(os.Args) > 1 {
		searchString = os.Args[1]
	}

	var completionItems []string = completion.GetCompletionItems(searchString, ".", true, "")
	for _, item := range completionItems {
		fmt.Println(item)
	}
}
