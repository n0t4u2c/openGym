// The StuFit release names its APK StuFit.apk: a fixed name, so
// github.com/n0t4u2c/openGym/releases/latest/download/StuFit.apk is a permanent direct link.
// The updater has to keep taking that file as the Standard APK and find its own checksum, or the
// phones that have the app could no longer update (.github/workflows/stufit-apk.yml).
import { describe, expect, it } from 'vitest'
import { pickApk, apkKind } from './update.js'

const a = name => ({ name, browser_download_url: 'https://github.com/n0t4u2c/openGym/releases/download/1.4.5/' + name })

describe('the StuFit release assets', () => {
  it('reads StuFit.apk as the Standard kind', () => {
    expect(apkKind('StuFit.apk')).toBe('standard')
  })

  it('picks StuFit.apk with its own checksum', () => {
    const { apk, hash } = pickApk(['StuFit.apk', 'StuFit.apk.sha256'].map(a), 'standard')
    expect(apk.name).toBe('StuFit.apk')
    expect(hash.name).toBe('StuFit.apk.sha256')
  })
})
