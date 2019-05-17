package main

import (
	"github.com/liserjrqlxue/simple-util"
	"os"
	"path/filepath"
)

func createWorkdir(workdir string, poolingList map[string]int, infoList map[string]info, poolingDirList, sampleDirList, laneDirList []string) error {
	for pooling := range poolingList {
		for _, subdir := range poolingDirList {
			err := os.MkdirAll(filepath.Join(workdir, pooling, subdir), 0755)
			simple_util.CheckErr(err)
		}
	}
	for sampleID, info := range infoList {
		for _, subdir := range sampleDirList {
			err := os.MkdirAll(filepath.Join(workdir, info.PoolingID, sampleID, subdir), 0755)
			simple_util.CheckErr(err)
		}
		for _, laneInfo := range info.LaneInfo {
			for _, subdir := range laneDirList {
				err := os.MkdirAll(filepath.Join(workdir, info.PoolingID, sampleID, subdir, laneInfo.LaneName), 0755)
				simple_util.CheckErr(err)
			}
		}
	}
	return nil
}
