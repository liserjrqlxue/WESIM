package main

import (
	"flag"
	"fmt"
	"github.com/360EntSecGroup-Skylar/excelize/v2"
	"github.com/liserjrqlxue/simple-util"
	"log"
	"os"
	"regexp"
	"strings"
)

var (
	xlsx = flag.String(
		"xlsx",
		"",
		"input xlsx",
	)
	prefix = flag.String(
		"prefix",
		"",
		"output prefix[prefix.sheetName.txt], default is same to -xlsx",
	)
	large = flag.Bool(
		"large",
		false,
		"if large xlsx",
	)
)

var (
	CRLF = regexp.MustCompile("\r\n")
	LF   = regexp.MustCompile("\n")
	TAB  = regexp.MustCompile("\t")
)

func main() {
	flag.Parse()
	if *xlsx == "" {
		flag.Usage()
		log.Fatalf("-xlsx as input is required")
	}
	if *prefix == "" {
		*prefix = *xlsx
	}

	xlsxFh, err := excelize.OpenFile(*xlsx)
	simple_util.CheckErr(err)
	for _, sheetName := range xlsxFh.GetSheetMap() {
		fileName := *prefix + "." + sheetName + ".txt"
		log.Printf("load sheet[%s] and write to [%s]", sheetName, fileName)
		fh, err := os.Create(fileName)
		simple_util.CheckErr(err)

		rows, err := xlsxFh.GetRows(sheetName)
		simple_util.CheckErr(err)

		for _, row := range rows {
			row = formatRow(row)
			_, err = fmt.Fprintln(fh, strings.Join(row, "\t"))
			simple_util.CheckErr(err)
		}

		simple_util.CheckErr(fh.Close())
	}
	log.Printf("End")
}

func formatRow(row []string) []string {
	for i := range row {
		row[i] = CRLF.ReplaceAllString(row[i], "<br>")
		row[i] = LF.ReplaceAllString(row[i], "<br>")
		row[i] = TAB.ReplaceAllString(row[i], " ")
	}
	return row
}
