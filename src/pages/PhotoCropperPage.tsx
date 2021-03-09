import React, {useState, useEffect} from 'react'
import {
  ScrollView,
  Image,
  View,
  TouchableOpacity,
  Text,
  StyleSheet,
  StatusBar,
  NativeSyntheticEvent,
  NativeScrollEvent,
} from 'react-native'
import type {NavigationProps} from 'react-native-awesome-navigation'
import {white, black, gray66} from '../utils/Colors'
import CameraNavigationBar from '../components/basic/CameraHeader'
import type {ImageResult} from '../components/NativeCamera'
import {cropPhotoToSquare} from '../bridge/NativeCameraBridge'
import {windowWidth} from '../components/video_player/styles'
import {OnNextStepNotification, UploadAvatarFailNotification, rxEventBus} from '../utils/RxEventBus'

interface Props extends NavigationProps {
  url: string
  scale: number
}

interface Point {
  x: number
  y: number
}

interface Size {
  width: number
  height: number
}

export const PhotoCropperPage = (props: Props) => {
  const [point, setPoint] = useState<Point>({x: 0, y: 0})
  const [imageSize, setImageSize] = useState<Size>({width: 0, height: 0})
  const [width, setWidth] = useState(0)
  const [scale, setScale] = useState(0)

  useEffect(() => {
    Image.getSize(props.url, (w, h) => {
      setScale(w / h)
      setImageSize({width: w, height: h})
      setWidth(Math.min(w, h))
    })
  }, [])

  const calculate = (event: NativeSyntheticEvent<NativeScrollEvent>) => {
    const trueLength = imageSize.width / event.nativeEvent.zoomScale
    const offset = event.nativeEvent.contentOffset
    const size = event.nativeEvent.contentSize
    setWidth(trueLength)
    const px = (offset.x / size.width) * imageSize.width
    const py = (offset.y / size.height) * imageSize.height
    setPoint({x: px, y: py})
  }

  const uploadAvatar = async () => {
    try {
      const result: ImageResult = await cropPhotoToSquare(props.url, point.x, point.y, width)
      await props.navigator.dismiss()
      rxEventBus.sendWithValue(OnNextStepNotification, {dataList: [result]})
    } catch (e) {
      rxEventBus.send(UploadAvatarFailNotification)
    }
  }

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" translucent />
      <CameraNavigationBar onPress={() => props.navigator.pop()} />
      <View style={{width: windowWidth, height: windowWidth}}>
        <View style={[styles.imageCover, {top: -100}]} />
        <View style={[styles.imageCover, {bottom: -100}]} />
        <ScrollView
          maximumZoomScale={2}
          minimumZoomScale={scale > 1 ? scale : 1}
          onMomentumScrollEnd={calculate}
          onScrollEndDrag={calculate}
          showsHorizontalScrollIndicator={false}
          showsVerticalScrollIndicator={false}
          style={{overflow: 'visible'}}
          zoomScale={scale > 1 ? scale : 1}>
          <Image
            source={{uri: props.url}}
            style={{width: windowWidth, height: windowWidth * props.scale}}
          />
        </ScrollView>
      </View>
      <View style={styles.bottomContainer}>
        <TouchableOpacity onPress={uploadAvatar} style={styles.buttonIcon}>
          <Text style={{color: white, fontSize: 18}}>下一步</Text>
        </TouchableOpacity>
      </View>
    </View>
  )
}

const styles = StyleSheet.create({
  container: {backgroundColor: white, flex: 1, justifyContent: 'space-between'},
  bottomContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    height: 72,
    backgroundColor: black,
    width: '100%',
  },
  imageCover: {
    backgroundColor: gray66,
    position: 'absolute',
    height: 100,
    width: '100%',
    zIndex: 1,
    opacity: 0.8,
  },
  buttonIcon: {
    justifyContent: 'center',
    alignItems: 'center',
    height: 40,
  },
})

PhotoCropperPage.navigationItem = {
  hideNavigationBar: true,
}
