# test.rb
require 'http'
require 'json'
require 'eventmachine'
require 'faye/websocket'

response = HTTP.post("https://slack.com/api/rtm.start", params: {
    token: ENV['SLACK_API_TOKEN1']
})

rc = JSON.parse(response.body)

url = rc['url']

EM.run do
  # Web Socketインスタンスの立ち上げ
  webSocket = Faye::WebSocket::Client.new(url)

  #  接続が確立した時の処理
  webSocket.on :open do
    p [:open]
  end

  # RTM APIから情報を受け取った時の処理
  # 接続が切断した時の処理
  webSocket.on :close do
    p [:close, event.code]
    webSocket = nil
    EM.stop
  end

  webSocket.on :message do |event|
    data = JSON.parse(event.data)
    p [:message, data]

    if data['text'] == 'こんにちは' then
      webSocket.send({
        type: 'message',
        text: "こんにちは <@#{data['user']}> ",
        channel: data['channel']
      }.to_json)
    elsif data['text'] == 'こんばんは' then
      webSocket.send({
        type: 'message',
        text: "こんばんは <@#{data['user']}> ",
        channel: data['channel']
        }.to_json)
    elsif data['text'] == 'おはよう' then
      webSocket.send({
        type: 'message',
        text: "こんにちは <@#{data['user']}> ",
        channel: data['channel']
      }.to_json)
    elsif data['text'] == '' then
      webSocket.send({
          type: 'message',
          text: 'message',
          channel: data['channel']
        }.to_json)
    end
  end
end
