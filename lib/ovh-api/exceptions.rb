module OVHApi
  class OVHApiError < RuntimeError; end
  class OVHApiNotConfiguredError < OVHApiError; end
end
