require 'spec/helper'
require 'chapter/source/session/cookie'

describe 'Cookie' do
  behaves_like :mock, :session

  should 'count every visit' do
    get('/').body.should == "This is your visit number 1"
    get('/').body.should == "This is your visit number 1"
    get('/').body.should == "This is your visit number 1"
  end

  should 'not count visit twice if sessions are enabled' do
    session do |mock|
      mock.get('/').body.should == 'This is your visit number 1'
      mock.get('/').body.should == 'This is your visit number 2'
    end
  end
end
