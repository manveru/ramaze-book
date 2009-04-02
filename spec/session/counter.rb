require 'spec/helper'
require 'chapter/source/session/counter'

describe 'Counter' do
  behaves_like :mock, :session

  should 'count every visit' do
    get('/').body.should == "You are visitor number 1"
    get('/').body.should == "You are visitor number 2"
    get('/').body.should == "You are visitor number 3"
  end

  should 'not count visit twice if sessions are enabled' do
    session do |mock|
      mock.get('/').body.should == 'You are visitor number 4'
      mock.get('/').body.should == 'You are visitor number 4'
    end
  end
end
