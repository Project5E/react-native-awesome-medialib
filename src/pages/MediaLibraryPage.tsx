import React, {useState, useCallback, useEffect} from 'react'
import {
  View,
  TouchableOpacity,
  Text,
  StyleSheet,
  Image,
  Platform,
  PermissionsAndroid,
  StatusBar,
} from 'react-native'
import {FlatList} from 'react-native-gesture-handler'
import {isIphoneX} from 'react-native-iphone-x-helper'
import {RootSiblingParent} from 'react-native-root-siblings'
import {useVisibleEffect} from 'react-native-awesome-navigation'
import ProgressHUD from '../components/basic/ProgressHUD'
import ThreeStageNavigationBar from '../components/basic/ThreeStageNavigationBar'
import {MediaLibrary} from '../components/NativeMediaLibraryView'
import {MediaLibraryBottomToolBar} from '../components/basic/MediaLibraryBottomToolBar'
import {MediaLibraryAlbumItem} from '../components/basic/MediaLibraryAlbumItem'
import {
  fetchAllAssets,
  fetchAllAlbums,
  requestLibraryAuthorization,
  requestCameraAuthorization,
  clear,
  startCameraPreview,
  stopCameraPreview,
  onSelectAlbumAtIndex,
  finishSelectMedia,
  fetchVideoURL,
  onNextStepPress,
} from '../bridge/MediaLibraryBridge'
import {black1A, white, black} from '../utils/Colors'
import {requestSinglePermission} from '../utils/PermissionChecker'
import {albumListStyle, processAlbumModel, showToast, AlbumModel, BaseProps} from '../utils/Utils'
import DismissButton from '../images/dismiss_white_button.png'
import DownArrow from '../images/down_white_arrow.png'
import {OnNextStepNotification, rxEventBus} from '../utils/RxEventBus'
import type {InvokeType} from '../utils/ResultModel'

interface Props extends BaseProps {
  // 最大选择数量
  maxSelectedMediaCount?: number
  // 是否只展示视频
  isVideoOnly?: boolean
  // 从哪里调用
  from: InvokeType
}

export const MediaLibraryPage = (props: Props) => {
  const [maxSelectedMediaCount] = useState<number>(props.maxSelectedMediaCount ?? 9)
  const [isVideoOnly] = useState<boolean>(props.isVideoOnly ?? false)
  const [selectedMediaCount, setSelectedMediaCount] = useState<number>(0)
  const [showProgressHUD, setShowProgressHUD] = useState<boolean>(false)
  const [currentAlbum, setCurrentAlbum] = useState<AlbumModel>()
  const [albumListVisable, setAlbumListVisable] = useState<boolean>(false)
  const [albumDataModel, setAlbumDataModel] = useState<AlbumModel[]>([])

  const initalLibrary = async (callback: (...parmas: any) => void) => {
    if (Platform.OS === 'ios') {
      const libraryAuthGranted = await requestLibraryAuthorization()
      if (libraryAuthGranted) fetchMediaResource()

      if (!isVideoOnly) {
        const cameraAuthGranted = await requestCameraAuthorization()
        if (cameraAuthGranted) startCameraPreview()
      }
    } else {
      const isAuthorized = await PermissionsAndroid.check(
        PermissionsAndroid.PERMISSIONS.READ_EXTERNAL_STORAGE
      )
      if (!isAuthorized) {
        requestSinglePermission(PermissionsAndroid.PERMISSIONS.READ_EXTERNAL_STORAGE, callback)
      } else {
        fetchMediaResource()
      }
    }
  }

  const readPermissionAndroidCallback = (granted: string) => {
    if (granted === PermissionsAndroid.RESULTS.GRANTED) {
      fetchMediaResource()
    } else {
      console.warn(`to do when deny permission`)
    }
  }

  const fetchMediaResource = async () => {
    fetchAllAssets(isVideoOnly)
    const res = await fetchAllAlbums()
    if (res && res.length > 0) {
      const models = processAlbumModel(res)
      setAlbumDataModel(models)
      // iOS首次进入默认展示第一个相册
      setCurrentAlbum(models[0])
    }
  }

  useVisibleEffect(
    props.screenID,
    useCallback(() => {
      startCameraPreview()
      return () => {
        stopCameraPreview()
      }
    }, [])
  )

  useEffect(() => {
    initalLibrary(readPermissionAndroidCallback)
    return () => {
      clear()
    }
  }, [])

  const bottomToolBar = () => {
    return props.isVideoOnly || albumListVisable ? null : (
      <MediaLibraryBottomToolBar
        onDoneButtonPress={onFinishSelect}
        selectedMediaCount={selectedMediaCount}
      />
    )
  }

  const progressHUD = () => <ProgressHUD color={white} />

  const renderItem = ({item}: {item: AlbumModel}) => {
    return (
      <MediaLibraryAlbumItem
        albumCount={item.count}
        albumCover={item.cover}
        albumName={item.name}
        onItemPress={() => onSelectAlbum(item)}
      />
    )
  }

  const onSelectAlbum = (item: AlbumModel) => {
    onSelectAlbumAtIndex(item.index)
    setAlbumListVisable(false)
    setCurrentAlbum(item)
  }

  const showAlbumList = async () => {
    if (albumListVisable) {
      setAlbumListVisable(false)
      return
    }

    if (albumDataModel.length > 0) {
      setAlbumListVisable(true)
      return
    }
    setShowProgressHUD(true)
    try {
      const res = await fetchAllAlbums()
      if (res && res.length > 0) {
        const models = processAlbumModel(res)
        setAlbumDataModel(models)
        setShowProgressHUD(false)
        setAlbumListVisable(true)
      }
    } catch (error) {
      setShowProgressHUD(false)
    }
  }

  const navigationLeft = () => (
    <View style={styles.navigationBarLeftItem}>
      <TouchableOpacity onPress={() => props.navigator.dismiss()}>
        <Image source={DismissButton} />
      </TouchableOpacity>
    </View>
  )

  const navigationMiddle = () => (
    <View>
      <TouchableOpacity
        activeOpacity={1}
        onPress={() => showAlbumList()}
        style={{flexDirection: 'row', alignItems: 'center'}}>
        <Text style={{fontSize: 16, fontWeight: '600', color: white}}>{currentAlbum?.name}</Text>
        {currentAlbum ? <Image source={DownArrow} /> : null}
      </TouchableOpacity>
    </View>
  )

  const onFinishSelect = async () => {
    onNextStepPress()
    setShowProgressHUD(true)
    try {
      const res = await finishSelectMedia()
      await props.navigator.dismiss()
      rxEventBus.sendWithValue(OnNextStepNotification, {dataList: res, from: props.from})
    } catch (error) {
      onShowToast('导出失败')
    } finally {
      setShowProgressHUD(false)
    }
  }

  const onPushCameraPage = () => {
    props.navigator.push('CameraPage')
  }

  const onPushPreviewPage = async () => {
    if (isVideoOnly) {
      try {
        const res = await fetchVideoURL()
        if (res) {
          props.navigator.push('VideoPreviewPage', {url: res.url, scale: res.scale})
        }
      } catch (error) {
        onShowToast(error.message)
      }
    } else {
      props.navigator.push('MediaLibraryPhotoPreviewPage', {from: props.from})
    }
  }

  const onShowToast = (desc: string) => {
    showToast(desc, isIphoneX() ? 119 : 98)
  }

  const onMediaItemSelect = (e: any) => {
    setSelectedMediaCount(e.nativeEvent.selectedMediaCount)
  }

  const onAlbumUpdate = (e: any) => {
    const newAlbums = e.nativeEvent.newAlbums
    const models = processAlbumModel(newAlbums)
    setAlbumDataModel(models)
  }

  return (
    <RootSiblingParent>
      <StatusBar backgroundColor={black} barStyle="light-content" />
      <View style={styles.container}>
        <ThreeStageNavigationBar
          leftItem={() => navigationLeft()}
          middleItem={() => navigationMiddle()}
          style={{backgroundColor: black1A}}
        />
        <MediaLibrary
          maxSelectedMediaCount={maxSelectedMediaCount}
          onAlbumUpdate={onAlbumUpdate}
          onMediaItemSelect={onMediaItemSelect}
          onPushCameraPage={onPushCameraPage}
          onPushPreviewPage={onPushPreviewPage}
          onShowToast={onShowToast}
          style={{flex: 1, width: '100%', height: '100%', backgroundColor: black1A}}
        />
        {bottomToolBar()}
        {albumListVisable ? (
          <FlatList
            data={albumDataModel}
            keyExtractor={item => item.index.toString()}
            renderItem={renderItem}
            style={albumListStyle.list}
          />
        ) : null}
        {showProgressHUD ? progressHUD() : null}
      </View>
    </RootSiblingParent>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    width: '100%',
    height: '100%',
    flexDirection: 'column',
    backgroundColor: black1A,
  },
  navigationBarLeftItem: {marginLeft: 16},
})

MediaLibraryPage.navigationItem = {
  hideNavigationBar: true,
}
