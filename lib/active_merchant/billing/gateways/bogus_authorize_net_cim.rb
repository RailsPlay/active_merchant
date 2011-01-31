module ActiveMerchant
  module Billing
    class BogusAuthorizeNetCimGateway < BogusGateway
      # CUSTOMER PROFILE
      @@customer_profiles = {}
      def create_customer_profile( opts )
        profile = opts[:profile]
        customer_id = profile.hash.to_s
        @@customer_profiles[customer_id] = {}
        update_customer_profile :profile => profile.merge( :customer_profile_id => customer_id )
      end

      def update_customer_profile( opts )
        profile = opts[:profile]
        customer_id = profile[:customer_profile_id]
        unless customer_id && @@customer_profiles.include?(customer_id)
          return Response.new( false, FAILURE_MESSAGE, {:error => "Unknown customer profile: #{customer_id}" }, :test => true )
        end

        @@customer_profiles[customer_id] = profile
        Response.new( true, SUCCESS_MESSAGE, {}, :authorization => customer_id, :test => true )
      end

      def delete_customer_profile( opts )
        profile = opts[:profile]
        unless (customer_id = profile[:customer_profile_id]).present && @@customer_profiles.include?(customer_id)
          return Response.new( false, FAILURE_MESSAGE, {:error => "Unknown customer profile: #{customer_id}" }, :test => true )
        end
        @@customer_profiles.delete customer_id
        Response.new( true, SUCCESS_MESSAGE, {}, :test => true )
      end

      @@payments = {}
      def self.payments()  @@payments  end

      def create_customer_profile_transaction( opts )
        txn = opts[:transaction]
        unless (customer_id = txn[:customer_profile_id]).present? && @@customer_profiles.include?(customer_id)
          return Response.new( false, FAILURE_MESSAGE, {:error => "Unknown customer profile: #{customer_id}" }, :test => true )
        end
        unless (profile_id = txn[:customer_payment_profile_id]).present? && @@payment_profiles.include?(profile_id)
          return Response.new( false, FAILURE_MESSAGE, {:error => "Unknown customer payment profile: #{profile_id}" }, :test => true )
        end

        (@@payments[customer_id] ||= []) << txn
        Response.new( true, SUCCESS_MESSAGE, {}, :authorization => txn.hash.to_s, :test => true )
      end

      # CUSTOMER PAYMENT PROFILE
      @@payment_profiles = {}
      def create_customer_payment_profile( opts )
        unless (customer_id = opts[:customer_profile_id]).present? && @@customer_profiles.include?(customer_id)
          return Response.new( false, FAILURE_MESSAGE, {:error => "Unknown customer profile: #{customer_id}" }, :test => true )
        end

        profile = opts[:payment_profile]
        profile_id = profile.hash.to_s
        @@payment_profiles[profile_id] = profile
        Response.new( true, SUCCESS_MESSAGE, { 'customer_payment_profile_id' => profile_id }, :test => true )
      end

      def update_customer_payment_profile( opts )
        unless (customer_id = opts[:customer_profile_id]).present? && @@customer_profiles.include?(customer_id)
          return Response.new( false, FAILURE_MESSAGE, {:error => "Unknown customer profile: #{customer_id}" }, :test => true )
        end

        profile = opts[:payment_profile]
        unless (profile_id = profile[:customer_payment_profile_id]).present? && @@payment_profiles.include?(profile_id)
          return Response.new( false, FAILURE_MESSAGE, {:error => "Unknown customer payment profile: #{profile_id}" }, :test => true )
        end

        @@payment_profiles[profile_id] = profile
        Response.new( true, SUCCESS_MESSAGE, {}, :authorization => profile_id, :test => true )
      end

      def delete_customer_payment_profile( opts )
        unless (customer_id = opts[:customer_profile_id]).present? && @@customer_profiles.include?(customer_id)
          return Response.new( false, FAILURE_MESSAGE, {:error => "Unknown customer profile: #{customer_id}" }, :test => true )
        end

        profile = opts[:payment_profile]
        unless (profile_id = profile[:customer_payment_profile_id]).present? && @@payment_profiles.include?(profile_id)
          return Response.new( false, FAILURE_MESSAGE, {:error => "Unknown customer payment profile: #{profile_id}" }, :test => true )
        end

        @@payment_profiles.delete profile_id
        Response.new( true, SUCCESS_MESSAGE, {}, :test => true )
      end

    end
  end
end
