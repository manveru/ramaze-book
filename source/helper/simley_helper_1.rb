module Ramaze
  module Helper
    module SimleyHelper
      FACES = {
        ':)' => '/smilies/smile.gif'
        ';)' => '/smilies/twink.gif'
      }
      REGEX = Regexp.union(*FACES.keys)

      def smile(string)
        string.gsub(REGEX){ FACES[$1] }
      end
    end
  end
end
