module ApplicationCable::CableUtil
  def will_send_to(obj)
    stream_for obj if obj
  end

  def will_broadcast
    key = self.class.to_s.gsub('Channel', '').downcase
    stream_from key
  end

  def will_broadcast_or_send_to(obj)
    stream_for obj if obj
    key = self.class.to_s.gsub('Channel', '').downcase
    stream_from key
  end

  def send_to(obj, data)
    self.class.broadcast_to obj, data
  end

  def broadcast(data)
    key = self.class.to_s.gsub('Channel', '').downcase
    ActionCable.server.broadcast key, data
  end

  def send_to_channel(channel, obj, data)
    "#{channel}_channel".camelize.constantize.broadcast_to obj, data
  end

  def broadcast_to_channel(channel, data)
    ActionCable.server.broadcast channel, data
  end
end
