module ActiveMerchant
  module Billing
    class BogusAuthorizeNetCimGateway < BogusGateway
      @@customers = {}
      def create_customer_profile( opts )
        profile = opts[:profile]
        cim_id = profile.hash.to_s
        @@customers[cim_id] = {}
        update_customer_profile :profile => profile.merge( :customer_profile_id => cim_id )
      end

      def update_customer_profile( opts )
        profile = opts[:profile]
        cim_id = profile.delete(:customer_profile_id)
        unless cim_id && @@customers.include?(cim_id)
          return Response.new( false, FAILURE_MESSAGE, {:error => "Unknown customer profile: #{cim_id}" }, :test => true )
        end

        @@customers[cim_id] = profile
        Response.new( true, SUCCESS_MESSAGE, {}, :authorization => cim_id, :test => true )
      end

      def delete_customer_profile( opts )
        profile = opts[:profile]
        cim_id = profile[:customer_profile_id]
        unless cim_id && @@customers.include?(cim_id)
          return Response.new( false, FAILURE_MESSAGE, {:error => "Unknown customer profile: #{cim_id}" }, :test => true )
        end
        @@customers.delete cim_id
        Response.new( true, SUCCESS_MESSAGE, {}, :test => true )
      end


      @@payments = {}
      def create_customer_payment_profile( profile )
        cim_id = profile.hash
        @@payments[cim_id] = profile
        Response.new( true, SUCCESS_MESSAGE, { 'customer_payment_profile_id' => cim_id }, :test => true )
      end

      def update_customer_payment_profile( profile )
        cim_id = profile[:customer_profile_id]
        unless cim_id && @@payments.include?(cim_id)
          return Response.new( false, FAILURE_MESSAGE, {:error => "Unknown customer payment profile: #{cim_id}" }, :test => true )
        end

        @@payments[cim_id] = profile
        Response.new( true, SUCCESS_MESSAGE, {}, :authorization => cim_id, :test => true )
      end

      def delete_customer_payment_profile( opts )
        cim_id = profile[:customer_profile_id]
        unless cim_id && @@customers.include?(cim_id)
          return Response.new( false, FAILURE_MESSAGE, {:error => "Unknown customer payment profile: #{cim_id}" }, :test => true )
        end
        @@payments.delete cim_id
        Response.new( true, SUCCESS_MESSAGE, {}, :test => true )
      end
    end
  end
end
