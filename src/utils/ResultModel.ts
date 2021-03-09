export interface LocalMedia {
  id?: number
  url: string
  width?: number
  height?: number
  scale?: number
  type?: SourceType
}

export enum InvokeType {
  main = 'main',
  editor = 'editor',
  avatar = 'avatar',
}

export enum SourceType {
  image = 'image',
  video = 'video',
}

export interface Result {
  dataList: LocalMedia[]
  from?: InvokeType
}
