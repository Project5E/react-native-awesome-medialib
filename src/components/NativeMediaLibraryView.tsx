import React from 'react'
import {requireNativeComponent, ViewStyle} from 'react-native'

const MediaLibraryView = requireNativeComponent('MediaLibraryView') as any

export interface MediaLibraryViewProps {
  style: ViewStyle
  maxSelectedMediaCount: number

  onMediaItemSelect(e: any): void
  onPushPreviewPage(): void
  onPushCameraPage(): void
  onShowToast(desc: string): void
  onAlbumUpdate(e: any): void
}

export const MediaLibrary = (props: MediaLibraryViewProps) => {
  return (
    <MediaLibraryView
      maxSelectedMediaCount={props.maxSelectedMediaCount}
      onAlbumUpdate={(e: any) => props.onAlbumUpdate(e)}
      onMediaItemSelect={(e: any) => props.onMediaItemSelect(e)}
      onPushCameraPage={() => props.onPushCameraPage()}
      onPushPreviewPage={() => props.onPushPreviewPage()}
      onShowToast={(e: any) => props.onShowToast(e.nativeEvent.desc)}
      style={props.style}
    />
  )
}
