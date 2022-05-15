package com.niharsystems;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Level;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.sql.SparkSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.net.URISyntaxException;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

public class WordCountVj {
    private static final String COMMA_DELIMITER = ",";
    private static final boolean isLocal = false;

    public static void main(String[] args) throws InterruptedException {
        Logger logger = LoggerFactory.getLogger(WordCountVj.class.getName());

        try {
            writeRDD(args);
        } catch (Exception ex) {
            System.out.println(ex.getMessage());
        }
        Thread.sleep(120000);

//        if (!isLocal) {
//            System.out.println("Done!");
//            while (true) {
//                Thread.sleep(10000);
//            }
//        }
    }

    private static void writeRDD(String[] args) throws URISyntaxException {
        org.apache.log4j.Logger.getLogger("org").setLevel(Level.ERROR);

        SparkSession spark = SparkSession
                .builder()
                .appName("spark-on-k8s-vj-WordCount")
                .getOrCreate();

        JavaRDD<String> videos;

        videos = spark.read().textFile(args[0]).javaRDD();//"USvideos.csv");

        JavaRDD<String> titles = videos
                .map(WordCountVj::extractTitle)
                .filter(StringUtils::isNotBlank);

        JavaRDD<String> words = titles.flatMap(title -> Arrays.asList(title
                .toLowerCase()
                .trim()
                .replaceAll("\\p{Punct}", "")
                .split(" ")).iterator());

        Map<String, Long> wordCounts = words.countByValue();
        List<Map.Entry> sorted = wordCounts.entrySet().stream()
                .sorted(Map.Entry.comparingByValue()).collect(Collectors.toList());

        for (Map.Entry<String, Long> entry : sorted) {
            System.out.println(entry.getKey() + " : " + entry.getValue());
        }

    }

    public static String extractTitle(String videoLine) {
        try {
            return videoLine.split(COMMA_DELIMITER)[2];
        } catch (ArrayIndexOutOfBoundsException e) {
            return "";
        }
    }
}