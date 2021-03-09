import {NativeModules} from 'react-native'
import type {ImageResult} from '../components/NativeCamera'

const cameraModule = NativeModules.CameraModule
export const takePhoto: (isSquare: boolean) => Promise<{url: string}> = cameraModule.takePhoto
export const switchCamera: () => void = cameraModule.switchCamera
export const deletePhoto: (uri: string) => void = cameraModule.deletePhoto
export const cropPhotoToSquare: (
  uri: string,
  x: number,
  y: number,
  width: number
) => Promise<ImageResult> = cameraModule.cropPhotoToSquare

export const startRunning: () => void = cameraModule.startRunning
export const stopRunning: () => void = cameraModule.stopRunning

export const saveImage: (url: string) => Promise<any> = cameraModule.saveImage
