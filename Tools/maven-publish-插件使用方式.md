---
title: maven-publish 插件使用方式
date: 2025-08-21 20:54:16
tags: maven
categories: 编程
---
maven-publish插件配置
<!-- more -->

```
apply plugin: 'maven-publish'
version = '1.0.0-SNAPSHOT'

publishing {
    publications {
        release(MavenPublication) {
            groupId "com.xlcx.modular"
            artifactId "syshook"
            version version

            // 发布 AAR
            artifact("$buildDir/outputs/aar/${project.name}-release.aar")

            // 可选：发布源码 JAR
            task sourcesJar(type: Jar) {
                from android.sourceSets.main.java.srcDirs
                archiveClassifier = 'sources'
            }
            artifact sourcesJar
        }
    }

    repositories {
        maven {
            credentials {
                username = getLocalProperty("MAVEN_USER")
                password = getLocalProperty("MAVEN_PASSWORD")
            }
            //推送到本地
//            url = uri('../plugin')
            url = uri(version.toString().contains("SNAPSHOT") ? "http://xxxx/repository/xxx-snapshots/" : "http://xxxx/repository/xxx-releases")
            allowInsecureProtocol = true
        }
    }
}

// 在文件末尾或任意位置添加（推荐放在 build.gradle 底部）
tasks.named("publishReleasePublicationToMavenRepository") {
    // 显式声明依赖：发布前先构建 release 变体
    dependsOn("assembleRelease")
}

def getLocalProperties() {
    def properties = new Properties()
    try {
        File localPropertiesFile = project.rootProject.file('local.properties')
        println("localPropertiesFile===:" + localPropertiesFile.absolutePath)
        properties.load(new FileInputStream(localPropertiesFile))
        return properties
    } catch (Exception e) {
        e.printStackTrace()
        return properties
    }
}

def getLocalProperty(String key) {
    try {
        return getLocalProperties().getProperty(key)
    } catch (Exception e) {
        e.printStackTrace()
        return ""
    }
}
```

在 `local.properties` 中添加

```
MAVEN_USER=xxx
MAVEN_PASSWORD=xxx
```

发布

```
Task -> publish -> publishReleasePublicationToMavenRepository
```
