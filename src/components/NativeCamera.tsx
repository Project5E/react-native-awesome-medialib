import {requireNativeComponent, ViewStyle} from 'react-native'
import React from 'react'

const CameraView = requireNativeComponent('CameraView') as any
export interface ImageResult {
  url: string
  width: number
  height: number
}

export interface CameraViewProps {
  style?: ViewStyle
}

export const CameraPreviewView = (props: CameraViewProps) => {
  return <CameraView style={props.style} />
}
