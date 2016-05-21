""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Speech.vim - Speech to text and text to speech via google speech api.  "
" Copyright (C) <2011>  Onur Aslan  <onur@onur.im>                       "
"               <2016>  Matthew Hague <matthewhague@zoho.com>            "
"                                                                        "
" Configure:                                                             "
" let g:SpeechGoogleApiKey='<your google speech api key>'                "
"                                                                        "
" Speech to text:                                                        "
" <Leader>r for record your voice and press again to convert to text and "
" append after cursor.                                                   "
"                                                                        "
" Text to speech:                                                        "
" <Leader>s to get speech of your current line.                          "
"                                                                        "
" Requiments: In order to run this script, you need sox (with flac       "
" encode support), wget and mplayer. This also works under UNIX like     "
" systems.                                                               "
"                                                                        "
" This script uses 'rec' to record your voice. If you have trouble when  "
" you recording your voice.  You can test your setup with:               "
"                                                                        "
" rec -r 16000 -c 1 test.flac
"                                                                        "
" You can change language with SpeechLang variable.                      "
"                                                                        "
" LICENSE:                                                               "
"                                                                        "
" This program is free software: you can redistribute it and/or modify   "
" it under the terms of the GNU General Public License as published by   "
" the Free Software Foundation, either version 3 of the License, or      "
" (at your option) any later version.                                    "
"                                                                        "
" This program is distributed in the hope that it will be useful,        "
" but WITHOUT ANY WARRANTY; without even the implied warranty of         "
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          "
" GNU General Public License for more details.                           "
"                                                                        "
" You should have received a copy of the GNU General Public License      "
" along with this program.  If not, see <http://www.gnu.org/licenses/>.  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:SpeechLang = 'en-us'

let s:SpeechToTextPid = 0

function! SpeechToText ()
  if !exists("g:SpeechGoogleApiKey")
    echo 'Please set g:SpeechGoogleApiKey'
    return
  endif

  if s:SpeechToTextPid == 0
    let x = system ('rm -rf /tmp/vimspeech.flac')
    let s:SpeechToTextPid = system ('rec ' .
                                    \ '-r 16000 ' .
                                    \ '-c 1 ' .
                                    \ '/tmp/vimspeech.flac > /dev/null 2>&1 & ' .
                                    \ 'echo $!')
    echo 'Speak now'
  else
    echo 'Converting...'
    let x = system ('kill -1 ' . s:SpeechToTextPid)
    let s:SpeechToTextPid = 0
    let result = system ('wget -q -U ' . shellescape ('Mozilla/5.0') .
                         \ ' --post-file=/tmp/vimspeech.flac' .
                         \ ' --header=' .
                         \ shellescape ('Content-Type: audio/x-flac; ' .
                         \              'rate=16000') .
                         \ ' -O - ' .
                         \ shellescape ('http://www.google.com/speech-api/v2/' .
                         \              'recognize?lang=' . g:SpeechLang .
                         \              '&client=chromium' .
                         \              '&key=' . g:SpeechGoogleApiKey))
    let match = matchlist (result, '.*"transcript":"\(.*\)",.*')
    if !exists('match[1]')
      echo 'Unable to determine voice'
      return
    endif
    exe ('normal a'.match[1].' ')
  endif
endfunction


function! TextToSpeech ()
  let string = getline ('.')
  echo 'Reading'
  let string = substitute (string, '[^A-Za-z0-9,. ]', '', 'g')
  let x = system ('mplayer ' .
                  \ shellescape ('http://translate.google.com/' . 
                                 \ 'translate_tts?ie=UTF-8&tl=' . g:SpeechLang .
                                 \ '&q=' . string) .
                  \ ' > /dev/null 2>&1')
endfunction


nnoremap <Leader>r :call SpeechToText()<CR>
nnoremap <Leader>s :call TextToSpeech()<CR>
