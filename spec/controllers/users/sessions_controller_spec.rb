# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::SessionsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
  end

  describe "DELETE #destroy" do
    it "preserves SAML session keys and redirects to IdP single logout" do
      session["saml_uid"] = "tester@umich.edu"
      session["saml_session_index"] = "session-index-1"

      delete :destroy

      expect(session["saml_uid"]).to eq("tester@umich.edu")
      expect(session["saml_session_index"]).to eq("session-index-1")
      expect(response).to redirect_to("#{user_saml_omniauth_authorize_path}/spslo")
    end

    it "falls back to the Devise sign-out path when SAML keys are missing" do
      session.delete("saml_uid")
      session.delete("saml_session_index")

      delete :destroy

      expect(response).to redirect_to(root_path)
    end

    it "does not use SAML SLO when only saml_uid is present" do
      session["saml_uid"] = "tester@umich.edu"
      session.delete("saml_session_index")

      delete :destroy

      expect(response).to redirect_to(root_path)
    end

    it "does not use SAML SLO when only saml_session_index is present" do
      session.delete("saml_uid")
      session["saml_session_index"] = "session-index-1"

      delete :destroy

      expect(response).to redirect_to(root_path)
    end
  end

  describe "#after_sign_out_path_for" do
    it "returns the SAML SLO path when both keys are present" do
      session["saml_uid"] = "tester@umich.edu"
      session["saml_session_index"] = "session-index-1"

      expect(controller.after_sign_out_path_for(user)).to eq(
        "#{user_saml_omniauth_authorize_path}/spslo"
      )
    end

    it "delegates to Devise when SAML keys are absent" do
      session.delete("saml_uid")
      session.delete("saml_session_index")

      expect(controller.after_sign_out_path_for(user)).to eq(root_path)
    end
  end
end
