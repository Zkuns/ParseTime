require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'User format birthday' do
    context 'birthday is normal date' do
      before { ENV['time_format'] = 'big_endian' }
      it 'success in big_endian type' do
        user = User.new(username: 'test', birthday: '2017, 05, 02')
        user.save
        expect(user.birthday).to eq Date.new(2017, 5, 2)
      end

      it 'success in little_endian type' do
        ENV['time_format'] = 'little_endian'
        user = User.new(username: 'test', birthday: '22-5-17')
        user.save
        expect(user.birthday).to eq Date.new(2017, 5, 22)
      end

      it 'success in middel_endian' do
        ENV['time_format'] = 'middle_endian'
        user = User.new(username: 'test', birthday: '9/23/17')
        user.save
        expect(user.birthday).to eq Date.new(2017, 9, 23)
      end
    end

    context 'chinese parse' do
      before { ENV['time_format'] = 'big_endian' }
      it 'success in chinese split' do
        user = User.new(username: 'test', birthday: '17年9月23日')
        user.save
        expect(user.birthday).to eq Date.new(2017, 9, 23)
      end

      it 'success in pure chinese' do
        user = User.new(username: 'test', birthday: '二零零九年一月二十一号')
        user.save
        expect(user.birthday).to eq Date.new(2009, 1, 21)
      end
    end

    context 'birthday is invalid' do
      before { ENV['time_format'] = 'big_endian' }
      it 'error when range wrong' do
        expect{
          User.new(username: 'test', birthday: '2018, 13, 02')
        }.to raise_error TimeparseException
      end

      it 'error when range wrong' do
        expect{
          User.new(username: 'test', birthday: '二零零九年二十月二十一号')
        }.to raise_error TimeparseException
      end

      it 'error when order wrong' do
        ENV['time_format'] = 'middle_endian'
        expect{
          User.new(username: 'test', birthday: '2018, 12, 01')
        }.to raise_error TimeparseException
      end
    end

  end
end
