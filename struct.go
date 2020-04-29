package main

import (
	"log"
	"strings"
	"time"

	"github.com/liserjrqlxue/goUtil/sge"
	"github.com/liserjrqlxue/libIM"
	//"github.com/liserjrqlxue/goUtil/sge"
)

func NewInfo(item map[string]string) libIM.Info {
	return libIM.Info{
		SampleID:     item["main_sample_num"],
		ChipCode:     item["chip_code"],
		Gender:       item["gender"],
		ProductCode:  item["product_code"],
		ProductType:  item["probuctType"],
		ProbandID:    item["proband_number"],
		HPO:          item["HPO"],
		StandardTag:  item["isStandardSample"],
		StandardQC:   item["StandardQC"],
		RelationShip: item["relationship"],
		QChistory:    item["QChistory"],
	}
}

func submitJob(job *libIM.Job) {
	libIM.Throttle <- true
	log.Printf("submit\t[%s]:[%s]", job.Step.Name, job.Id)
	var hjid = job.WaitPriorChan()
	log.Printf("start\t[%s]:[%s]:[%s]", job.Step.Name, job.Id, job.Sh)
	if *submit != "" {
		sge.WrapSubmit("submit.sh", job.Sh, strings.Join(hjid, ","), nil)
	}
	time.Sleep(10 * time.Second)
	job.Done(job.Id)
	log.Printf("finish\t[%s]:[%s]", job.Step.Name, job.Id)
	<-libIM.Throttle
}
