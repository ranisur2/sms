-- Multi-Institution School Management Database Schema (MySQL 8+)

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS attendance_records;
DROP TABLE IF EXISTS attendance_sessions;
DROP TABLE IF EXISTS result_items;
DROP TABLE IF EXISTS exam_results;
DROP TABLE IF EXISTS exam_subjects;
DROP TABLE IF EXISTS exams;
DROP TABLE IF EXISTS class_subjects;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS student_guardians;
DROP TABLE IF EXISTS student_enrollments;
DROP TABLE IF EXISTS sections;
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS academic_sessions;
DROP TABLE IF EXISTS shifts;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS institutions;
DROP TABLE IF EXISTS staff_profiles;
DROP TABLE IF EXISTS student_profiles;
DROP TABLE IF EXISTS guardian_profiles;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE institutions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    short_name VARCHAR(100) NULL,
    eiin_no VARCHAR(30) NULL,
    phone VARCHAR(30) NULL,
    email VARCHAR(120) NULL,
    website VARCHAR(150) NULL,
    address_line TEXT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(120) NULL,
    phone VARCHAR(30) NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('SUPER_ADMIN','ADMIN','OPERATOR','TEACHER','GUARDIAN','STAFF','STUDENT') NOT NULL,
    status ENUM('ACTIVE','INACTIVE','BLOCKED') NOT NULL DEFAULT 'ACTIVE',
    last_login_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_users_username_inst (institution_id, username),
    UNIQUE KEY uq_users_email_inst (institution_id, email),
    CONSTRAINT fk_users_institution
        FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE student_profiles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NULL,
    student_code VARCHAR(50) NOT NULL,
    roll_no VARCHAR(30) NULL,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NULL,
    gender ENUM('MALE','FEMALE','OTHER') NULL,
    date_of_birth DATE NULL,
    blood_group VARCHAR(5) NULL,
    religion VARCHAR(30) NULL,
    present_address TEXT NULL,
    permanent_address TEXT NULL,
    admission_date DATE NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_student_code_inst (institution_id, student_code),
    UNIQUE KEY uq_roll_inst (institution_id, roll_no),
    CONSTRAINT fk_student_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_student_user FOREIGN KEY (user_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE guardian_profiles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NULL,
    guardian_code VARCHAR(50) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    relation_type ENUM('FATHER','MOTHER','BROTHER','SISTER','UNCLE','AUNT','OTHER') NOT NULL DEFAULT 'OTHER',
    phone VARCHAR(30) NULL,
    email VARCHAR(120) NULL,
    occupation VARCHAR(120) NULL,
    address TEXT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_guardian_code_inst (institution_id, guardian_code),
    CONSTRAINT fk_guardian_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_guardian_user FOREIGN KEY (user_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE staff_profiles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NULL,
    staff_code VARCHAR(50) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    staff_type ENUM('TEACHER','OPERATOR','ACCOUNTANT','LIBRARIAN','DRIVER','SECURITY','OFFICE_ASSISTANT','OTHER') NOT NULL,
    designation VARCHAR(120) NULL,
    joining_date DATE NULL,
    phone VARCHAR(30) NULL,
    email VARCHAR(120) NULL,
    salary DECIMAL(12,2) NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_staff_code_inst (institution_id, staff_code),
    CONSTRAINT fk_staff_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_staff_user FOREIGN KEY (user_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE academic_sessions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_session_name_inst (institution_id, name),
    CONSTRAINT fk_session_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE shifts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(50) NOT NULL,
    start_time TIME NULL,
    end_time TIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_shift_name_inst (institution_id, name),
    CONSTRAINT fk_shift_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE classes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(50) NOT NULL,
    numeric_order INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_class_name_inst (institution_id, name),
    CONSTRAINT fk_class_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sections (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    class_id BIGINT UNSIGNED NOT NULL,
    shift_id BIGINT UNSIGNED NULL,
    name VARCHAR(20) NOT NULL,
    room_no VARCHAR(20) NULL,
    capacity INT NULL,
    class_teacher_staff_id BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_section_inst_class_shift_name (institution_id, class_id, shift_id, name),
    CONSTRAINT fk_section_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_section_class FOREIGN KEY (class_id) REFERENCES classes(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_section_shift FOREIGN KEY (shift_id) REFERENCES shifts(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_section_class_teacher FOREIGN KEY (class_teacher_staff_id) REFERENCES staff_profiles(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE groups (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    class_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_group_inst_class_name (institution_id, class_id, name),
    CONSTRAINT fk_group_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_group_class FOREIGN KEY (class_id) REFERENCES classes(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE student_enrollments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    student_id BIGINT UNSIGNED NOT NULL,
    academic_session_id BIGINT UNSIGNED NOT NULL,
    class_id BIGINT UNSIGNED NOT NULL,
    section_id BIGINT UNSIGNED NOT NULL,
    group_id BIGINT UNSIGNED NULL,
    shift_id BIGINT UNSIGNED NULL,
    roll_no VARCHAR(30) NULL,
    status ENUM('ACTIVE','TRANSFERRED','DROPPED','PASSED') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_enroll_student_session (student_id, academic_session_id),
    UNIQUE KEY uq_enroll_roll_context (institution_id, academic_session_id, class_id, section_id, roll_no),
    CONSTRAINT fk_enroll_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_enroll_student FOREIGN KEY (student_id) REFERENCES student_profiles(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_enroll_session FOREIGN KEY (academic_session_id) REFERENCES academic_sessions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_enroll_class FOREIGN KEY (class_id) REFERENCES classes(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_enroll_section FOREIGN KEY (section_id) REFERENCES sections(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_enroll_group FOREIGN KEY (group_id) REFERENCES groups(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_enroll_shift FOREIGN KEY (shift_id) REFERENCES shifts(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE student_guardians (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    student_id BIGINT UNSIGNED NOT NULL,
    guardian_id BIGINT UNSIGNED NOT NULL,
    is_primary TINYINT(1) NOT NULL DEFAULT 0,
    emergency_contact TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_student_guardian (student_id, guardian_id),
    CONSTRAINT fk_student_guardian_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_student_guardian_student FOREIGN KEY (student_id) REFERENCES student_profiles(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_student_guardian_guardian FOREIGN KEY (guardian_id) REFERENCES guardian_profiles(id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE subjects (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    code VARCHAR(30) NOT NULL,
    name VARCHAR(120) NOT NULL,
    is_optional TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_subject_code_inst (institution_id, code),
    CONSTRAINT fk_subject_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE class_subjects (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    academic_session_id BIGINT UNSIGNED NOT NULL,
    class_id BIGINT UNSIGNED NOT NULL,
    group_id BIGINT UNSIGNED NULL,
    subject_id BIGINT UNSIGNED NOT NULL,
    assigned_teacher_staff_id BIGINT UNSIGNED NULL,
    full_mark DECIMAL(6,2) NOT NULL DEFAULT 100,
    pass_mark DECIMAL(6,2) NOT NULL DEFAULT 33,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_class_subject (institution_id, academic_session_id, class_id, group_id, subject_id),
    CONSTRAINT fk_cs_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cs_session FOREIGN KEY (academic_session_id) REFERENCES academic_sessions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cs_class FOREIGN KEY (class_id) REFERENCES classes(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cs_group FOREIGN KEY (group_id) REFERENCES groups(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_cs_subject FOREIGN KEY (subject_id) REFERENCES subjects(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cs_teacher FOREIGN KEY (assigned_teacher_staff_id) REFERENCES staff_profiles(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE exams (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    academic_session_id BIGINT UNSIGNED NOT NULL,
    class_id BIGINT UNSIGNED NOT NULL,
    section_id BIGINT UNSIGNED NULL,
    name VARCHAR(100) NOT NULL,
    exam_type ENUM('MONTHLY','MIDTERM','FINAL','MODEL_TEST','ADMISSION','OTHER') NOT NULL DEFAULT 'OTHER',
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_exam_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_exam_session FOREIGN KEY (academic_session_id) REFERENCES academic_sessions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_exam_class FOREIGN KEY (class_id) REFERENCES classes(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_exam_section FOREIGN KEY (section_id) REFERENCES sections(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE exam_subjects (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    exam_id BIGINT UNSIGNED NOT NULL,
    class_subject_id BIGINT UNSIGNED NOT NULL,
    exam_date DATE NULL,
    max_mark DECIMAL(6,2) NOT NULL DEFAULT 100,
    pass_mark DECIMAL(6,2) NOT NULL DEFAULT 33,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_exam_subject (exam_id, class_subject_id),
    CONSTRAINT fk_exam_subject_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_exam_subject_exam FOREIGN KEY (exam_id) REFERENCES exams(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_exam_subject_class_subject FOREIGN KEY (class_subject_id) REFERENCES class_subjects(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE exam_results (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    exam_id BIGINT UNSIGNED NOT NULL,
    student_enrollment_id BIGINT UNSIGNED NOT NULL,
    total_obtained DECIMAL(8,2) NULL,
    gpa DECIMAL(4,2) NULL,
    grade VARCHAR(5) NULL,
    rank_in_class INT NULL,
    status ENUM('PASSED','FAILED','INCOMPLETE') NOT NULL DEFAULT 'INCOMPLETE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_exam_result_student (exam_id, student_enrollment_id),
    CONSTRAINT fk_exam_result_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_exam_result_exam FOREIGN KEY (exam_id) REFERENCES exams(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_exam_result_enrollment FOREIGN KEY (student_enrollment_id) REFERENCES student_enrollments(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE result_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    exam_result_id BIGINT UNSIGNED NOT NULL,
    exam_subject_id BIGINT UNSIGNED NOT NULL,
    obtained_mark DECIMAL(6,2) NOT NULL,
    grade VARCHAR(5) NULL,
    grade_point DECIMAL(4,2) NULL,
    is_absent TINYINT(1) NOT NULL DEFAULT 0,
    remark VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_result_item_unique (exam_result_id, exam_subject_id),
    CONSTRAINT fk_result_item_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_result_item_result FOREIGN KEY (exam_result_id) REFERENCES exam_results(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_result_item_exam_subject FOREIGN KEY (exam_subject_id) REFERENCES exam_subjects(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE attendance_sessions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    academic_session_id BIGINT UNSIGNED NOT NULL,
    class_id BIGINT UNSIGNED NOT NULL,
    section_id BIGINT UNSIGNED NOT NULL,
    attendance_date DATE NOT NULL,
    shift_id BIGINT UNSIGNED NULL,
    created_by_user_id BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_attendance_session (institution_id, academic_session_id, class_id, section_id, attendance_date, shift_id),
    CONSTRAINT fk_attn_session_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_attn_session_session FOREIGN KEY (academic_session_id) REFERENCES academic_sessions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_attn_session_class FOREIGN KEY (class_id) REFERENCES classes(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_attn_session_section FOREIGN KEY (section_id) REFERENCES sections(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_attn_session_shift FOREIGN KEY (shift_id) REFERENCES shifts(id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_attn_session_creator FOREIGN KEY (created_by_user_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE attendance_records (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    institution_id BIGINT UNSIGNED NOT NULL,
    attendance_session_id BIGINT UNSIGNED NOT NULL,
    student_enrollment_id BIGINT UNSIGNED NOT NULL,
    status ENUM('PRESENT','ABSENT','LATE','LEAVE') NOT NULL,
    check_in_time TIME NULL,
    note VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_attendance_record (attendance_session_id, student_enrollment_id),
    CONSTRAINT fk_attn_record_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_attn_record_session FOREIGN KEY (attendance_session_id) REFERENCES attendance_sessions(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_attn_record_enrollment FOREIGN KEY (student_enrollment_id) REFERENCES student_enrollments(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
