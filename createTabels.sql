-- RUN FIRST !!!!
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
----

-- Table: admin
CREATE TABLE IF NOT EXISTS public.admin (
    id_admin UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    password TEXT NOT NULL
);

-- Table: attendance
CREATE TABLE IF NOT EXISTS public.attendance (
    id_attendance UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date_data DATE,
    attendance_json JSONB
);

-- Table: counter
CREATE TABLE IF NOT EXISTS public.counter (
    id_counter UUID PRIMARY KEY DEFAULT gen_random_uuid()
);

-- Table: feedback
CREATE TABLE IF NOT EXISTS public.feedback (
    id_feedback UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_user UUID,
    id_report UUID,
    rating_value INTEGER,
    feedback_date DATE,
    description TEXT,
    id_token UUID,
    CONSTRAINT fk_feedback_user FOREIGN KEY (id_user) REFERENCES public.user(id_user),
    CONSTRAINT fk_feedback_report FOREIGN KEY (id_report) REFERENCES public.report(id_report),
    CONSTRAINT fk_feedback_token FOREIGN KEY (id_token) REFERENCES public.booking(id_token)
);

-- Table: waiting_queue_token
CREATE TABLE IF NOT EXISTS public.waiting_queue_token (
    id_token UUID,
    priority INTEGER,
    start_time TIME,
    end_time TIME,
    is_paused BOOLEAN DEFAULT FALSE,
    pause_time TIME,
    pause_end_time TIME,
    is_attended BOOLEAN DEFAULT FALSE,
    id_staff UUID,
    id_waiting_queue UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    CONSTRAINT fk_token FOREIGN KEY (id_token) REFERENCES public.booking(id_token),
    CONSTRAINT fk_staff FOREIGN KEY (id_staff) REFERENCES public.staff(id_staff)
);

-- Table: schedule
CREATE TABLE IF NOT EXISTS public.schedule (
    id_schedule UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    schedule_json JSONB,
    schedule_date DATE
);

-- Table: booking
CREATE TABLE IF NOT EXISTS public.booking (
    id_token UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_user UUID,
    id_counter UUID,
    id_report UUID,
    id_service UUID,
    booking_date DATE,
    issue_time TIME,
    CONSTRAINT fk_booking_user FOREIGN KEY (id_user) REFERENCES public.user(id_user),
    CONSTRAINT fk_booking_counter FOREIGN KEY (id_counter) REFERENCES public.counter(id_counter),
    CONSTRAINT fk_booking_report FOREIGN KEY (id_report) REFERENCES public.report(id_report),
    CONSTRAINT fk_booking_service FOREIGN KEY (id_service) REFERENCES public.service(id_service)
);

-- Trigger: insert trigger for waiting queue
CREATE OR REPLACE TRIGGER trigger_update_waiting_queue
AFTER INSERT ON public.booking
FOR EACH ROW
EXECUTE FUNCTION public.update_waiting_queue();

-- Table: qrcode
CREATE TABLE IF NOT EXISTS public.qrcode (
    id_qrcode UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    qr_lifetime INTEGER,
    id_token UUID,
    qr_code TEXT,
    CONSTRAINT fk_qrcode_token FOREIGN KEY (id_token) REFERENCES public.booking(id_token)
);

-- Table: staff
CREATE TABLE IF NOT EXISTS public.staff (
    id_staff UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    password TEXT NOT NULL,
    rating INTEGER
);

-- Trigger: rating evaluation
CREATE OR REPLACE TRIGGER trigger_update_rating
BEFORE INSERT OR UPDATE ON public.staff
FOR EACH ROW
EXECUTE FUNCTION public.evaluate_staff_rating();

-- Table: user
CREATE TABLE IF NOT EXISTS public.user (
    id_user UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT NOT NULL,
    address TEXT NOT NULL,
    postal_code INTEGER,
    email TEXT,
    password TEXT NOT NULL
);

-- Table: service_counter
CREATE TABLE IF NOT EXISTS public.service_counter (
    id_service_session UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_counter UUID,
    id_staff UUID,
    id_token UUID,
    service_date DATE,
    service_start TIMESTAMP,
    service_end TIMESTAMP,
    CONSTRAINT fk_service_counter_counter FOREIGN KEY (id_counter) REFERENCES public.counter(id_counter),
    CONSTRAINT fk_service_counter_staff FOREIGN KEY (id_staff) REFERENCES public.staff(id_staff),
    CONSTRAINT fk_service_counter_token FOREIGN KEY (id_token) REFERENCES public.booking(id_token)
);

-- Table: service
CREATE TABLE IF NOT EXISTS public.service (
    id_service UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_type TEXT,
    priority INTEGER NOT NULL
);
