import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const SUPABASE_URL = 'https://kobehvlsddcffsaeejcw.supabase.co'
const SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_1PIvWyIYtcntTuj6-NsXYw_sc7AKRHX'

export const supabase = createClient(
    SUPABASE_URL,
    SUPABASE_PUBLISHABLE_KEY
)