require 'test_helper'

class SagePayFormNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @options = {:credential2 => 'EncryptionKey123'}
  end

  def test_successful_purchase
    n = SagePayForm::Notification.new(successful_purchase, @options)
    assert n.complete?

    assert_equal 'Completed', n.status
    assert_equal 'OK', n.status_code
    assert_equal 'Successfully Authorised Transaction', n.message
    assert_equal '28', n.item_id
    assert_equal '{2D370B0B-692D-4D07-B616-91B86CCDF85A}', n.transaction_id
    assert_equal '7349', n.auth_id
    assert_equal '31.47', n.gross
    assert_equal 'ALL MATCH', n.avs_cv2_result
    assert_equal 'MATCHED', n.address_result
    assert_equal 'MATCHED', n.post_code_result
    assert_equal 'MATCHED', n.cv2_result
    assert_equal 'OK', n.buyer_auth_result
    assert_equal 'MNG8ZAJDJRUKW90GGYZNTH', n.buyer_auth_result_code
    assert_equal 'VISA', n.credit_card_type
    assert_equal '8356', n.credit_card_last_4_digits

    assert_false n.gift_aid?
    assert_false n.payer_verified?
    assert_false n.test?

    assert_nil n.address_status
    assert_nil n.currency
  end

  def test_failed_purchase
    n = SagePayForm::Notification.new(failed_purchase, @options)
    assert_false n.complete?

    assert_equal 'Failed', n.status
    assert_equal 'NOTAUTHED', n.status_code
    assert_equal 'NOTAUTHED message generated by Simulator', n.message
    assert_equal '28', n.item_id
    assert_equal '{2D370B0B-692D-4D07-B616-91B86CCDF85A}', n.transaction_id
    assert_equal '31.47', n.gross
    assert_equal 'ALL MATCH', n.avs_cv2_result
    assert_equal 'MATCHED', n.address_result
    assert_equal 'MATCHED', n.post_code_result
    assert_equal 'MATCHED', n.cv2_result
    assert_equal 'OK', n.buyer_auth_result
    assert_equal 'MNVJYYXXHMCNH0BOTBT97Z', n.buyer_auth_result_code
    assert_equal 'VISA', n.credit_card_type
    assert_equal '4353', n.credit_card_last_4_digits

    assert_false n.gift_aid?
    assert_false n.payer_verified?
    assert_false n.test?

    assert_nil n.auth_id
    assert_nil n.address_status
    assert_nil n.currency
  end

  def test_compositions
    n = SagePayForm::Notification.new(successful_purchase, @options)
    assert_equal Money.new(3147, nil), n.amount
  end

  def test_bogus_crypt
    assert_raises SagePayForm::Notification::InvalidCryptData do
      SagePayForm::Notification.new('crypt=SomeInvalidCryptField', @options)
    end
  end

  def test_missing_crypt
    assert_raises SagePayForm::Notification::MissingCryptData do
      SagePayForm::Notification.new('other=stuff', @options)
    end
  end

  def test_missing_key
    assert_raises SagePayForm::Notification::MissingCryptKey do
      SagePayForm::Notification.new(successful_purchase, {})
    end
  end

  private

  def successful_purchase
    'utm_nooverride=1&crypt=FhoCBgwDSSYkSBgRGEVHQAELFxMQHEk6Gg0oAApCVEYpAhpSOAUAAQAcIhYcVRJnNw8NARgTAAAAAG0zHF9WXDc6GzEWFBFUXVZtMyliZksMCl4JSzRHXl8seydUBwsBAUNXNklHWStZX31IQABwC3MtIDY/SEEoEkgfHThERlsLAV5FSkRNTy4DJBAXRQ8AdEBXRV8xIjosOHlYOH1+EwgvNzExVjUNCxwuFgpjV0AwAhdPNDEgKicrD0MpXkFHBgEHFysVBxwDGnYoOGVxewAqRTEvQiYMHBsnEUR8c2cGJiY2XzcdDxsvIgFEARQAAT0GEQwCETobDz8QCgx9eGMtIiQvTTknKFYRJDN1eGEQJTRLSTczMDUgHy1fclNBIToaAhxNIiA8L20pGEJGBwEHBBsNA0lRXFt9'
  end

  def failed_purchase
    'utm_nooverride=1&crypt=FhoCBgwDSScgOgowLXl3d2M9FxMNBQctChoqDBUMfHwRLzYmMTUwSQILOBYYVlcTIgsNFwsRAAwLTikcWWJbXjACAgYWAlI/CgAvCgtlSnAqCgZPS0hSPz89Hx0wVQ9IdypQRUkyRCtCWHJXPRwGd3VZTjBPQUJEVl8JXU9ycXcDVlYzBFY1BAAbJRFEAgMdcVlFMy8jNz9dUwopNRF/chEtK1Q4FBAbCh04NxxCR18xUy4zLTM8LCtIGwoKRXFcIQsxFwoFGB1SIwoxOnl3d2MtNUArFQccAxp2KDhlcXsAKkU1EBYAKAYKdlVfAnZgIA0WABwjAAgbGzhYNnoUcAQ4NU80PiIjNjcTPTF8cX0NXiE9LTIgUFg0bSYYQ1ZnPB4GTy85JyhJIioWDQV2WiIHFwFEREdcXA=='
  end
end
