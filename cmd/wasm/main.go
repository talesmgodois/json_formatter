package main

import (
	"encoding/json"
	"fmt"
	"syscall/js"
)

func main() {
	fmt.Println("Web assembly, json formatter") // fmt.PrintLn Will works as a console.log
	js.Global().Set("formatJSON", jsonWrapper())
	<-make(chan struct{})
}

func prettyJson(input string) (string, error) {
	var raw any
	if err := json.Unmarshal([]byte(input), &raw); err != nil {
		return "", err
	}
	pretty, err := json.MarshalIndent(raw, "", "  ")
	if err != nil {
		return "", err
	}
	return string(pretty), nil
}

func jsonWrapper() js.Func {
	jsonFunc := js.FuncOf(func(this js.Value, args []js.Value) any {
		if len(args) != 1 {
			return "Invalid no of arguments passed"
		}
		inputJson := args[0].String()
		pretty, err := prettyJson(inputJson)
		if err != nil {
			fmt.Println("unable to convert json %s\n", err)
			return err.Error()
		}
		return pretty
	})

	return jsonFunc
}
