class User < ApplicationRecord
  include TimeFormatable

  need_format_time :birthday
end
