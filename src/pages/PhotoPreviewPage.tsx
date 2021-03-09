import React from 'react'
import {View, TouchableOpacity, Text, StyleSheet, StatusBar, Dimensions} from 'react-native'
import type {NavigationProps} from 'react-native-awesome-navigation'
import FastImage from 'react-native-fast-image'
import {saveImage, deletePhoto} from '../bridge/NativeCameraBridge'
import CameraNavigationBar from '../components/basic/CameraHeader'
import {black, white} from '../utils/Colors'

const windowWidth = Dimensions.get('window').width
interface Props extends NavigationProps {
  url: string
  scale: number
}

export const PhotoPreviewPage = (props: Props) => {
  return (
    <View style={styles.container}>
      <StatusBar backgroundColor={black} barStyle="light-content" />
      <CameraNavigationBar onPress={() => props.navigator.pop()} />
      <FastImage
        source={{uri: props.url}}
        style={{width: windowWidth, height: windowWidth * props.scale}}
      />
      <View style={styles.bottomContainer}>
        <TouchableOpacity
          onPress={() => {
            deletePhoto(props.url)
            props.navigator.pop()
          }}
          style={[styles.buttonIcon, styles.buttonLeft]}>
          <Text style={styles.photobuttonText}>重拍</Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={async () => {
            await saveImage(props.url) // 保存图片到本地相册
            props.navigator.popPages(2)
          }}
          style={[styles.buttonIcon, styles.buttonRight]}>
          <Text style={styles.photobuttonText}>确定</Text>
        </TouchableOpacity>
      </View>
    </View>
  )
}

PhotoPreviewPage.navigationItem = {
  hideNavigationBar: true,
}

const styles = StyleSheet.create({
  container: {flex: 1, backgroundColor: black, justifyContent: 'space-between'},
  bottomContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    height: 72,
    width: '100%',
    marginBottom: 20,
  },
  buttonIcon: {
    justifyContent: 'space-between',
    alignItems: 'center',
    height: 40,
    width: 40,
  },
  buttonLeft: {
    marginLeft: 40,
  },
  buttonRight: {
    marginRight: 40,
  },
  takePhotoIcon: {
    height: 72,
    width: 72,
  },
  photobuttonText: {
    color: white,
    fontSize: 18,
  },
})
