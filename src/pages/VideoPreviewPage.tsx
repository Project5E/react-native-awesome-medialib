import React, {useState} from 'react'
import {View, TouchableOpacity, Text, StyleSheet, StatusBar} from 'react-native'
import type {NavigationProps} from 'react-native-awesome-navigation'
import Video from 'react-native-video'
import {isIphoneX} from 'react-native-iphone-x-helper'
import CameraNavigationBar from '../components/basic/CameraHeader'
import {black, white} from '../utils/Colors'
import {showToast} from '../utils/Utils'
import {windowWidth} from '../components/video_player/styles'
import {onNextStepPress} from '../bridge/MediaLibraryBridge'
import {OnNextStepNotification, rxEventBus} from '../utils/RxEventBus'

interface Props extends NavigationProps {
  id: number
  url: string
  scale: number
}

export const VideoPreviewPage = (props: Props) => {
  const [progress, setProgress] = useState(0)
  const onCompress = async () => {
    try {
      onNextStepPress()
      await props.navigator.dismiss()
      rxEventBus.sendWithValue(OnNextStepNotification, {
        dataList: [{id: props.id, url: props.url, scale: props.scale}],
      })
    } catch (error) {
      showToast('导出失败')
    }
  }
  return (
    <View style={styles.container}>
      <StatusBar backgroundColor={black} barStyle="light-content" />
      <CameraNavigationBar onPress={() => props.navigator.pop()} />
      <View style={[styles.progressBar, {width: windowWidth * progress}]} />
      <Video
        onProgress={data => setProgress(data.currentTime / data.seekableDuration)}
        resizeMode="contain"
        source={{uri: props.url}}
        style={{flex: 1}}
      />
      <View style={styles.bottomContainer}>
        <TouchableOpacity onPress={onCompress} style={styles.buttonIcon}>
          <Text style={{color: white, fontSize: 18}}>下一步</Text>
        </TouchableOpacity>
      </View>
    </View>
  )
}

VideoPreviewPage.navigationItem = {
  hideNavigationBar: true,
}

const styles = StyleSheet.create({
  container: {flex: 1, backgroundColor: black, justifyContent: 'space-between'},
  header: {
    width: '100%',
    height: isIphoneX() ? 88 : 64,
    justifyContent: 'flex-end',
  },
  progressBar: {height: 1, backgroundColor: white, marginTop: 10},
  backIconContainer: {
    justifyContent: 'center',
    height: 28,
    width: 28,
    marginLeft: 16,
  },
  backIcon: {width: 28, height: 28, tintColor: white},
  bottomContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    height: 72,
    width: '100%',
    marginBottom: 10,
  },
  buttonIcon: {
    justifyContent: 'center',
    alignItems: 'center',
    height: 40,
  },
})
