---
title: ffmpeg deprecated 方法替换
date: 2019-02-24 22:02:03
tags: ffmpeg
categories: 音视频
---

FFmpeg 3.4.x 中废弃了老版本中的部分函数，这里总结下替换方法。

<!-- more -->

## AVCodecContext 获取

deprecated ：

```c
AVCodecContext *pCodecCtx;
AVFormatContext *pFormatCtx = avformat_alloc_context();
//...some code
pCodecCtx = pFormatCtx->streams[i]->codec;//deprecated
```

替换:

```c
AVFormatContext *pFormatCtx = avformat_alloc_context();
//...some code
AVCodecParameters *avCodecParameters = pFormatCtx->streams[videoStream]->codecpar;
AVCodecContext *pCodecCtx = avcodec_alloc_context3(NULL);
if (!pCodecCtx) {
    LOGE("alloc avcodec fail.");
    return -1;
}
ret = avcodec_parameters_to_context(pCodecCtx, avCodecParameters);
if (ret < 0) {
    LOGE("avcodec_parameters_to_context fail.");
}
```

## avcodec_decode_video2()

视频读取 老版本

```c
int frameFinished;
AVPacket packet;

while(av_read_frame(pFormatCtx, &packet)>=0) {
    //判断是否为视频流
    if(packet.stream_index==videoStream) {
        //对该帧进行解码
        avcodec_decode_video2(pCodecCtx, pFrame, &frameFinished, &packet);
        if (frameFinished) {
            // lock native window
            ANativeWindow_lock(nativeWindow, &windowBuffer, 0);
            // 格式转换
            sws_scale(sws_ctx, (uint8_t const * const *)pFrame->data,
                      pFrame->linesize, 0, pCodecCtx->height,
                      pFrameRGBA->data, pFrameRGBA->linesize);
            // 获取stride
            uint8_t * dst = windowBuffer.bits;
            int dstStride = windowBuffer.stride * 4;
            uint8_t * src = pFrameRGBA->data[0];
            int srcStride = pFrameRGBA->linesize[0];
            // 由于window的stride和帧的stride不同,因此需要逐行复制
            int h;
            for (h = 0; h < videoHeight; h++) {
                memcpy(dst + h * dstStride, src + h * srcStride, (size_t) srcStride);
            }
            ANativeWindow_unlockAndPost(nativeWindow);
        }
        //延迟等待
        usleep((unsigned long) (1000 * 40 * play_rate));
    }
    av_packet_unref(&packet);
}
```

替代方法:

```c
AVPacket *packet = av_packet_alloc();
while (av_read_frame(pFormatCtx, packet) >= 0) {
    //判断 Packet （音视频压缩数据） 是否是视频流
    if (packet->stream_index == videoStream) {
        //解码视频帧 : 老版本使用
        //avcodec_decode_video2(pCodecCtx, pFrame, &frameFinished, &packet);

        ret = avcodec_send_packet(pCodecCtx, packet);
        if (ret < 0) {
            LOGE("video Error sending a packet for decoding.");
            break;
        }
        while (ret >= 0) {
            ret = avcodec_receive_frame(pCodecCtx, pFrame);
            if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
                break;
            } else if (ret < 0) {
                LOGE("Error during decoding\n");
                break;
            }
            //锁住 NativeWindow 缓冲区
            ANativeWindow_lock(nativeWindow, &windowBuffer, 0);

            //格式转换
            sws_scale(swsContext, (uint8_t const *const *) pFrame->data,
                      pFrame->linesize, 0, pCodecCtx->height,
                      pFrameRGBA->data, pFrameRGBA->linesize);

            //获取 stride
            uint8_t *dst = windowBuffer.bits;
            int dstStride = windowBuffer.stride * 4;
            uint8_t *src = (uint8_t *) (pFrameRGBA->data[0]);
            int srcStride = pFrameRGBA->linesize[0];
            //由于窗口的stride和帧的stride不同，因此需要逐行复制
            for (int h = 0; h < videoHeight; h++) {
                memcpy(dst + h * dstStride, src + h * srcStride, (size_t) srcStride);
            }
            ANativeWindow_unlockAndPost(nativeWindow);
        }
    }
    av_packet_unref(packet);
}
```

## avcodec_decode_audio4()

老方法 :

```c
while (av_read_frame(avFormatCtx, &packet) >= 0) {
   int frameFinished = 0;
   // Is this a packet from the audio stream?
   if (packet.stream_index == audioStream) {
       avcodec_decode_audio4(avCodecCtx, avFrame, &frameFinished, &packet);

       //解码完一帧数据
       if (frameFinished) {
           // data_size为音频数据所占的字节数
           int data_size = av_samples_get_buffer_size(
                   avFrame->linesize, avCodecCtx->channels,
                   avFrame->nb_samples, avCodecCtx->sample_fmt, 1);
           LOGD(">> getPcm data_size=%d", data_size);
           // 这里内存再分配可能存在问题
           if (data_size > outputBufferSize) {
               outputBufferSize = (size_t) data_size;
               outputBuffer = (uint8_t *) realloc(outputBuffer,
                                                  sizeof(uint8_t) * outputBufferSize);
           }

           // 音频格式转换
           swr_convert(swrCtx, &outputBuffer, avFrame->nb_samples,
                       (uint8_t const **) (avFrame->extended_data),
                       avFrame->nb_samples);

           // 返回pcm数据
           *pcm = outputBuffer;
           *pcmSize = (size_t) data_size;
           return 0;
       }
   }
}
```

新方法 : 

```c
Packet *packet;

// 获取PCM数据, 自动回调获取
int getPCM(void **pcm, size_t *pcmSize) {
    int ret = 0;
    //LOGI("getPCM.\n");
    packet = av_packet_alloc();
    while (av_read_frame(avFormatCtx, packet) >= 0) {
        if (packet->stream_index == audioStream) {
            ret = avcodec_send_packet(avCodecCtx, packet);
            if (ret < 0) {
                LOGE("audio Error sending a packet for decoding.");
                break;
            }
            while (avcodec_receive_frame(avCodecCtx, avFrame) == 0) {
                // data_size为音频数据所占的字节数
                int data_size = av_samples_get_buffer_size(
                        avFrame->linesize, avCodecCtx->channels,
                        avFrame->nb_samples, avCodecCtx->sample_fmt, 1);
                // LOGI(">> while getPcm data_size=%d\n", data_size);
                // 内存再分配
                if (data_size > outputBufferSize) {
                    outputBufferSize = (size_t) data_size;
                    outputBuffer = realloc(outputBuffer, sizeof(uint8_t) * outputBufferSize);
                }
                // 音频格式转换
                swr_convert(swrCtx, &outputBuffer, avFrame->nb_samples,
                            (uint8_t const **) (avFrame->extended_data),
                            avFrame->nb_samples);
                // 返回pcm数据
                *pcm = outputBuffer;
                *pcmSize = (size_t) data_size;
                return 0;
            }
        }
    }
    return -1;
}
```


