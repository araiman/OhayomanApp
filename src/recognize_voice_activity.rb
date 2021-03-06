# encoding: utf-8
require 'ruboto/activity'
require 'ruboto/util/toast'

java_import 'android.speech.RecognizerIntent'
java_import 'android.speech.SpeechRecognizer'
java_import 'android.speech.RecognitionListener'
java_import 'android.content.Intent'
java_import 'android.media.MediaPlayer'
java_import 'android.media.AudioManager'
java_import 'android.net.Uri'
java_import 'android.util.Log'

class RecognizeVoiceActivity
  def on_create(bundle)
    super
    set_title 'Recognize Speeches'

    context = getApplicationContext
    start_recognize_voice(context)
  end

  def start_recognize_voice(context)
    recognition_listner = SpeechListener.new(self)
    @speech_recognizer = SpeechRecognizer.create_speech_recognizer(context)
    @speech_recognizer.set_recognition_listener(recognition_listner)
    intent = Intent.new(RecognizerIntent::ACTION_RECOGNIZE_SPEECH)
    intent.putExtra(RecognizerIntent::EXTRA_LANGUAGE, 'ja_JP')
    intent.putExtra(RecognizerIntent::EXTRA_LANGUAGE_MODEL,
                    RecognizerIntent::LANGUAGE_MODEL_FREE_FORM)
    intent.putExtra(RecognizerIntent::EXTRA_PROMPT, 'Please Speech')

    # TODO 音声をミュートに変更する処理の追加

    @speech_recognizer.start_listening(intent)
  end
end

class SpeechListener
  def initialize(activity)
    @activity = activity
    @context = activity.getApplicationContext
  end

  def hashCode
    hash
  end

  def onBeginningOfSpeech
  end

  def onBufferReceived(_buffer)
  end

  def onEndOfSpeech
  end

  def onError(error)
    context = @activity.getApplicationContext
    # REVIEW スタイルガイドに忠実に従えば、if文で改行すべきだが、これくらいなら改行しない方が読みやすいのでは？
    @activity.start_ruboto_activity 'RecognizeVoiceActivity' if error == 6 || error == 7
  end

  def onEvent(_event_type, _params)
  end

  def onPartialResults(_partial_results)
  end

  def onReadyForSpeech(_params)
  end

  def onResults(results)
    # TODO 音声を最大にする処理の追加


    result = results.get_string_array_list(SpeechRecognizer::RESULTS_RECOGNITION)

    # TODO 挨拶のバリエーションを増やした時に、各挨拶の最後の数字がランダムで変わるように変更
    if result[0] == 'おはよう' \
      || result[0] == 'おはよー' \
      || result[0] == 'おはよ' \
      || result[0] == 'おはようございます' \
      || result[0] == 'はようございます' \
      || result[0] == 'おはよう ございます'

      # ohayo_num = rand(8)
      # play_greeting([:ohayo][ohayo_num])
      play_greeting(:ohayo)
      launch_recognize_voice_after_playback

    elsif result[0] == 'こんにちは' \
      || result[0] == 'こんにちわ' \
      || result[0] == 'こんちは' \
      || result[0] == 'こんちわ'

      # TODO こんにちはの音声準備と、play_greetingメソッドを動くように
      launch_recognize_voice_after_playback

    elsif result[0] == 'お疲れ様です' \
      || result[0] == 'お疲れさまです' \
      || result[0] == 'おつかれさまです' \
      || result[0] == 'お疲れ' \
      || result[0] == 'おつかれ' \
      || result[0] == 'お先に失礼します' \
      || result[0] == '咲いています' \
      || result[0] == 'します' \
      || result[0] == '先にします'

      otsukare_num = rand(12)
      play_greeting([:otsukare][otsukare_num])
      play_greeting([:ohayo][ohayo_num])
      launch_recognize_voice_after_playback
    end
  end

  def onRmsChanged(_rmsdB)
  end

  private

  def launch_recognize_voice_after_playback
    loop do
      unless @player.isPlaying
        @activity.start_ruboto_activity 'RecognizeVoiceActivity'
        break
      end
    end
  end

  def play_greeting(greeting)
    # ohayo_resid = [R.raw.ohayo1, R.raw.ohayo2]
    # otsukare_resid = [R.raw.otsukare1, R.raw.otsukare2, R.raw.otsukare3, R.raw.otsukare4, R.raw.otsukare5, R.raw.otsukare6, R.raw.otsukare7, R.raw.otsukare8, R.raw.otsukare9, R.raw.otsukare10, R.raw.otsukare11, R.raw.otsukare12]

    # greetings = { ohayo: ohayo_resid, otsukare: otsukare_resid }
    # Log.v 'debug', "#{greetings}"
    # Log.v 'debug', "#{greetings[greeting]}"
    # @player = MediaPlayer.create(@context, greetings[greeting])

    # TODO もし，MediaPlayerを使い回せなかったら，有効に戻す
    @player = MediaPlayer.create(@context, R.raw.ohayo1)
    @player.start
  end
end

class AudioFocus
  def onAudioFocusChange(_focusChange)
    nil
  end

  def toString
    self.class.to_s
  end
end
