#
# This is a patch to Ruby's standard IMAP library to support GMail's IMAP
# extensions, notably X-GM-MSGID and X-GM-THRID 
#
# see: http://code.google.com/apis/gmail/imap/
#

require 'net/imap'

Net::IMAP::ResponseParser.class_eval do
  
  private
  
  def msg_att
    match(T_LPAR)
    attr = {}
    while true
      token = lookahead
      case token.symbol
      when T_RPAR
        shift_token
        break
      when T_SPACE
        shift_token
        token = lookahead
      end
      case token.value
      when /\A(?:ENVELOPE)\z/ni
        name, val = envelope_data
      when /\A(?:FLAGS)\z/ni
        name, val = flags_data
      when /\A(?:INTERNALDATE)\z/ni
        name, val = internaldate_data
      when /\A(?:RFC822(?:\.HEADER|\.TEXT)?)\z/ni
        name, val = rfc822_text
      when /\A(?:RFC822\.SIZE)\z/ni
        name, val = rfc822_size
      when /\A(?:BODY(?:STRUCTURE)?)\z/ni
        name, val = body_data
      when /\A(?:UID)\z/ni
        name, val = uid_data
        
      #
      # This is what's new 
      # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      #
      when /\A(?:X-GM-THRID)\z/ni
        name, val = uid_data
      when /\A(?:X-GM-MSGID)\z/ni
        name, val = uid_data
      #
      # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
      #
        
      else
        parse_error("unknown attribute `%s'", token.value)
      end
      attr[name] = val
    end
    return attr
  end

  
end