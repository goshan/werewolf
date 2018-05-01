module ApplicationCable
  class Channel < ActionCable::Channel::Base
    include EasyLogin
    include CableUtil
  end
end
