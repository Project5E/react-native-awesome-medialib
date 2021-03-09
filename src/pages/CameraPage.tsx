import React, {useEffect, useState} from 'react'
import {
  View,
  TouchableOpacity,
  StyleSheet,
  Image,
  StatusBar,
  PermissionsAndroid,
  Platform,
} from 'react-native'
import {isIphoneX} from 'react-native-iphone-x-helper'
import type {NavigationProps} from 'react-native-awesome-navigation'
// import DeviceInfo from 'react-native-device-info'
import {CameraPreviewView} from '../components/NativeCamera'
import {windowWidth} from '../components/video_player/styles'
import CameraNavigationBar from '../components/basic/CameraHeader'
import TAKE_PHOTO_ICON from '../images/take_photo_button.png'
import SWITCH_CAMERA from '../images/switch_camera.png'
import CAMERA_RATIO_ONE from '../images/camera_ratio_one.png'
import CAMERA_RATIO_43 from '../images/camera_ratio_43.png'
import {black, white} from '../utils/Colors'
import {startRunning, stopRunning, switchCamera, takePhoto} from '../bridge/NativeCameraBridge'

export const CameraPage = (props: NavigationProps) => {
  const [height, setHeight] = useState((windowWidth * 4) / 3)
  const isSquare = () => {
    return height === windowWidth
  }

  const androidCheckPermission = () => {
    PermissionsAndroid.check(PermissionsAndroid.PERMISSIONS.CAMERA).then(async response => {
      if (!response) {
        const granted = await PermissionsAndroid.request(PermissionsAndroid.PERMISSIONS.CAMERA)
        if (granted === PermissionsAndroid.RESULTS.GRANTED) {
          startRunning()
        } else {
          props.navigator.pop()
        }
      }
      // const osVersion = +DeviceInfo.getSystemVersion()
      // if (osVersion < 10) {
      // checWriteExternalStoragePermission()
      // }
    })
  }

  useEffect(() => {
    if (Platform.OS === 'ios') {
      startRunning()
    } else {
      androidCheckPermission()
    }
    return () => {
      stopRunning()
    }
  }, [])
  return (
    <View style={styles.container}>
      <StatusBar backgroundColor={black} barStyle="light-content" />
      <CameraNavigationBar onPress={() => props.navigator.pop()} />
      <CameraPreviewView style={{width: windowWidth, height}} />
      <View style={styles.bottomContainer}>
        <TouchableOpacity
          onPress={() => {
            if (height === windowWidth) {
              setHeight((windowWidth * 4) / 3)
            } else {
              setHeight(windowWidth)
            }
          }}
          style={styles.buttonIcon}>
          <Image
            source={isSquare() ? CAMERA_RATIO_ONE : CAMERA_RATIO_43}
            style={{width: 28, height: 28}}
          />
        </TouchableOpacity>
        <TouchableOpacity
          onPress={async () => {
            const pathResult = await takePhoto(isSquare())
            Image.getSize(
              pathResult.url,
              (w, h) => {
                const combine = {...pathResult, scale: h / w}
                props.navigator.push('PhotoPreviewPage', combine)
              },
              err => {
                console.warn(`fail:${err}`)
              }
            )
          }}
          style={styles.takePhotoIcon}>
          <Image source={TAKE_PHOTO_ICON} style={{width: 72, height: 72}} />
        </TouchableOpacity>
        <TouchableOpacity
          onPress={() => {
            switchCamera()
          }}
          style={styles.buttonIcon}>
          <Image source={SWITCH_CAMERA} style={{width: 28, height: 28}} />
        </TouchableOpacity>
      </View>
    </View>
  )
}

CameraPage.navigationItem = {
  hideNavigationBar: true,
}

const styles = StyleSheet.create({
  container: {flex: 1, backgroundColor: black, justifyContent: 'space-between'},
  header: {
    width: '100%',
    height: isIphoneX() ? 86 : 44,
    justifyContent: 'flex-end',
  },
  backIconContainer: {
    justifyContent: 'center',
    height: 28,
    width: 28,
    marginLeft: 16,
  },
  backIcon: {width: 28, height: 28, tintColor: white},
  bottomContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    height: 72,
    width: '100%',
    marginBottom: isIphoneX() ? 20 : 0,
  },
  buttonIcon: {
    justifyContent: 'center',
    alignItems: 'center',
    height: 40,
    width: 40,
  },
  takePhotoIcon: {
    height: 72,
    width: 72,
  },
})
