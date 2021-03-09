/* eslint-disable max-classes-per-file */
import {Subject} from 'rxjs'
import {filter, map} from 'rxjs/operators'

export class Event {
  name: string
  value: any

  constructor(name: string, value: any) {
    this.name = name
    this.value = value
  }
}

class RxEventBus {
  private readonly eventSubject: Subject<any>
  constructor() {
    this.eventSubject = new Subject()
  }

  send = (name: string, value: any = null) => {
    const event = new Event(name, value)
    this.eventSubject.next(event)
  }

  sendWithValue = (key: string, value: any) => {
    const event = new Event(key, value)
    this.eventSubject.next(event)
  }

  listen = (name: string) => {
    return this.eventSubject.pipe(
      filter((e: Event) => e.name === name),
      map((e: Event) => e.value)
    )
  }

  open = () => this.eventSubject.pipe()
}

export const rxEventBus = new RxEventBus()
export const OnNextStepNotification = 'OnNextStepNotification'
export const UploadAvatarFailNotification = 'UploadAvatarFailNotification'
