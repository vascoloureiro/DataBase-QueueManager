
-- Table: admin
CREATE TABLE IF NOT EXISTS public.admin (
    id_admin UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_admin TEXT NOT NULL,
    email_admin TEXT NOT NULL,
    password_admin TEXT NOT NULL
);

-- Table: app_user (renomeado para evitar conflito com palavra reservada)
CREATE TABLE IF NOT EXISTS public.app_user (
    id_user UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_user TEXT NOT NULL,
    address_user TEXT NOT NULL,
    email_user TEXT NOT NULL,
    password_user TEXT NOT NULL
);

-- Table: staff
CREATE TABLE IF NOT EXISTS public.staff (
    id_staff UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_staff TEXT NOT NULL,
    email_staff TEXT NOT NULL,
    password_staff TEXT NOT NULL
);

-- Table: schedule
CREATE TABLE IF NOT EXISTS public.schedule (
    id_schedule UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    schedule_json JSONB,
    schedule_date DATE
);

-- Table: counter
CREATE TABLE IF NOT EXISTS public.counter (
    id_counter UUID PRIMARY KEY DEFAULT gen_random_uuid()
);

-- Table: report
CREATE TABLE IF NOT EXISTS public.report (
    id_report UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    path_report TEXT NOT NULL,
    report_timestamp TIMESTAMP
);

-- Table: stats_day
CREATE TABLE IF NOT EXISTS public.stats_day (
    date_stats DATE PRIMARY KEY,
    median_time_per_day INTEGER
);

-- Table: stats_counter
CREATE TABLE IF NOT EXISTS public.stats_counter (
    fk_date_stats DATE REFERENCES public.stats_day(date_stats),
    id_counter UUID,
    median_time_service INTEGER,
    morning_clients INTEGER,
    evening_clients INTEGER,
    CONSTRAINT ifk_d_counter FOREIGN KEY (id_counter) REFERENCES public.counter(id_counter)
);

-- Table: service
CREATE TABLE IF NOT EXISTS public.service (
    id_service UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type_service TEXT NOT NULL,
    priority INTEGER NOT NULL
);

-- Table: booking
CREATE TABLE IF NOT EXISTS public.booking (
    id_token UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_user UUID NOT NULL,
    id_counter UUID NOT NULL,
    id_report UUID,
    id_service UUID NOT NULL,
    booking_date DATE NOT NULL,
    issue_time TIME,
    CONSTRAINT fk_booking_user FOREIGN KEY (id_user) REFERENCES public.app_user(id_user),
    CONSTRAINT fk_booking_counter FOREIGN KEY (id_counter) REFERENCES public.counter(id_counter),
    CONSTRAINT fk_booking_report FOREIGN KEY (id_report) REFERENCES public.report(id_report),
    CONSTRAINT fk_booking_service FOREIGN KEY (id_service) REFERENCES public.service(id_service)
);

-- Table: waiting_queue
CREATE TABLE IF NOT EXISTS public.waiting_queue (
    id_waiting_queue UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_token UUID NOT NULL,
    priority INTEGER,
    start_time TIME,
    end_time TIME,
    is_paused BOOLEAN DEFAULT FALSE,
    pause_time TIME,
    end_pause_time TIME,
    is_attended BOOLEAN DEFAULT FALSE,
    id_staff UUID,
    CONSTRAINT fk_token FOREIGN KEY (id_token) REFERENCES public.booking(id_token),
    CONSTRAINT fk_staff FOREIGN KEY (id_staff) REFERENCES public.staff(id_staff)
);

-- Table: service_counter
CREATE TABLE IF NOT EXISTS public.service_counter (
    id_service_session UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_counter UUID NOT NULL,
    id_staff UUID NOT NULL,
    id_token UUID NOT NULL,
    service_date DATE NOT NULL,
    service_start TIMESTAMP,
    service_end TIMESTAMP,
    CONSTRAINT fk_service_counter_counter FOREIGN KEY (id_counter) REFERENCES public.counter(id_counter),
    CONSTRAINT fk_service_counter_staff FOREIGN KEY (id_staff) REFERENCES public.staff(id_staff),
    CONSTRAINT fk_service_counter_token FOREIGN KEY (id_token) REFERENCES public.booking(id_token)
);

-- Table: priority_token
CREATE TABLE IF NOT EXISTS public.priority_token (
    id_token_priority UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    priority INTEGER NOT NULL,
    issue_date DATE NOT NULL
);

-- Table: feedback
CREATE TABLE IF NOT EXISTS public.feedback (
    id_feedback UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_user UUID NOT NULL,
    id_report UUID,
    rating_value INTEGER,
    feedback_date DATE,
    description TEXT,
    id_token UUID NOT NULL,
    CONSTRAINT fk_feedback_user FOREIGN KEY (id_user) REFERENCES public.app_user(id_user),
    CONSTRAINT fk_feedback_report FOREIGN KEY (id_report) REFERENCES public.report(id_report),
    CONSTRAINT fk_feedback_token FOREIGN KEY (id_token) REFERENCES public.booking(id_token)
);

-- Table: qrcode
CREATE TABLE IF NOT EXISTS public.qrcode (
    id_qrcode UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    qr_lifetime INTEGER,
    id_token UUID NOT NULL,
    qr_code TEXT NOT NULL,
    CONSTRAINT fk_qrcode_token FOREIGN KEY (id_token) REFERENCES public.booking(id_token)
);

-- Trigger: insert trigger for waiting queue
CREATE OR REPLACE TRIGGER trigger_update_waiting_queue
AFTER INSERT ON public.booking
FOR EACH ROW
EXECUTE FUNCTION public.update_waiting_queue();

-- Trigger: rating evaluation
CREATE OR REPLACE TRIGGER trigger_update_rating
BEFORE INSERT OR UPDATE ON public.staff
FOR EACH ROW
EXECUTE FUNCTION public.evaluate_staff_rating();