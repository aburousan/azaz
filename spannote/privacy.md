+++
title = "SpanNote privacy"
hascode = false
tags = ["spannote"]
+++

~~~
<script>document.documentElement.classList.remove('dark-mode');</script>
~~~

# SpanNote privacy

*Last updated 18 October 2026. [Back to SpanNote](/spannote/)*

SpanNote is a notebook app. It has no account, no ads and no tracking of its own. Your notes are files on your device, and they leave it only when you choose to send them somewhere.

## What is stored, and where

Notebooks, pictures, PDFs you import, cover photos, sound recordings and settings are stored in the app's private storage on your device. Uninstalling the app removes them, so keep a backup.

## Backups and sync (only if you switch them on)

You can back up to a folder you pick (on the device or a memory card), to your own WebDAV server such as Nextcloud, or to your Google Drive, and keep several tablets the same through your Google Drive, your WebDAV server or a private GitHub repository you own. Files go straight from your device to the place you chose. The app's maker never receives them.

- WebDAV works only over an encrypted (https) connection, so your password is never sent in the open.
- The WebDAV password and the GitHub token are kept encrypted on your device, with a key held by Android that cannot be copied off the device.
- With Google Drive, SpanNote can see only the files it makes itself, not the rest of your Drive. Signing in is handled by Google on your device.

## Buying the full app

The free app has up to 5 notebooks with up to 30 pages each. The full app is one purchase through Google Play. Google handles the payment; SpanNote and its maker never see your card or payment details. The app asks Google Play only whether the full app was bought on your Google account, and keeps that answer on the device. Nothing you have written is ever locked, bought or not.

## Sharing a notebook as a link (only if you choose)

Share as a link makes a PDF of the notebook in your own Google Drive, in a folder called SpanNote shared, and sets it so that anyone with the link can see it without signing in. The PDF is stored by Google in your Drive, not by us. Anyone you give the link to, and anyone they pass it on to, can see the notebook. Stop sharing deletes that PDF, and the link then no longer opens.

## Microphone

The microphone is used only while you are recording, after you press the microphone button and allow it. Recordings are saved inside the notebook on your device.

## Camera and pictures

When you take a photo, Android's camera app takes it and gives it to SpanNote; SpanNote does not use the camera itself. Pictures you add, and a photo you choose as a notebook cover, are copied into the app's storage on your device.

## Reading handwriting

- **Maths.** SpanNote has its own maths reader. It runs entirely on your device and does not need the internet.
- **Search and text.** To search handwriting and read written words, SpanNote uses Google's ML Kit handwriting recognition, which also runs on your device. The first time, it downloads a language model (about 20 MB) from Google. Your writing is read on the device and is not sent to Google or anyone else. Google's ML Kit library may send anonymous usage and performance information to Google; see Google's ML Kit terms. You can turn handwriting search off in Settings › Search.

## Helping to improve the maths reader (only if you choose)

You can teach SpanNote your handwriting (Settings › Maths), write the formulas it shows you (Write maths for the reader) and correct its readings (select maths with the lasso, then Teach this maths). These samples stay on your device.

If you want to help make the reader better, Settings › Maths › Help improve the handwriting reader opens your own email app with the samples attached, addressed to spannotes@gmail.com. Nothing is sent unless you press send in your email app. The samples contain only the pen strokes and what they say; they are used only to train SpanNote's handwriting reader. You can delete the samples on your device at any time, and you can ask us by email to delete samples you sent.

## Internet

The app uses the internet only to download the handwriting search model, to check the full-app purchase with Google Play and, if you set them up, for backups and sync. The 3D anatomy and molecule stickers are inside the app and need no internet; the anatomy models come from BodyParts3D (© The Database Center for Life Science, CC BY 4.0).

## Children

SpanNote is not made for children under 13 and does not knowingly collect anything from them.

## Contact

Questions: **spannotes@gmail.com**
