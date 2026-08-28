package com.brightfuture.config;

import com.brightfuture.entity.*;
import com.brightfuture.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DataInitializer.class);

    private final UserRepository userRepository;
    private final CourseRepository courseRepository;
    private final LabBookingRepository labBookingRepository;
    private final PrintOrderRepository printOrderRepository;
    private final PasswordEncoder passwordEncoder;
    private final String adminEmail;
    private final String adminPassword;

    public DataInitializer(
            UserRepository userRepository,
            CourseRepository courseRepository,
            LabBookingRepository labBookingRepository,
            PrintOrderRepository printOrderRepository,
            PasswordEncoder passwordEncoder,
            @Value("${app.admin.email:admin@brightfuture.best.com}") String adminEmail,
            @Value("${app.admin.default-password:Admin@BrightFuture2026!}") String adminPassword) {
        this.userRepository = userRepository;
        this.courseRepository = courseRepository;
        this.labBookingRepository = labBookingRepository;
        this.printOrderRepository = printOrderRepository;
        this.passwordEncoder = passwordEncoder;
        this.adminEmail = adminEmail;
        this.adminPassword = adminPassword;
    }

    @Override
    @Transactional
    public void run(String... args) {
        seedUsers();
        seedCourses();
        seedSampleData();
    }

    private void seedUsers() {
        // Admin Account
        if (!userRepository.existsByEmailIgnoreCase(adminEmail)) {
            User admin = User.builder()
                    .email(adminEmail)
                    .fullName("Bright Future Administrator")
                    .phone("+255 700 000 001")
                    .passwordHash(passwordEncoder.encode(adminPassword))
                    .role(Role.ADMIN)
                    .build();
            userRepository.save(admin);
            log.info("Provisioned default admin account: {}", adminEmail);
        }

        // Demo Student Account
        String demoStudentEmail = "student@brightfuture.best.com";
        if (!userRepository.existsByEmailIgnoreCase(demoStudentEmail)) {
            User student = User.builder()
                    .email(demoStudentEmail)
                    .fullName("Amina Mwangi")
                    .phone("+255 712 345 678")
                    .passwordHash(passwordEncoder.encode("Student@123!"))
                    .role(Role.STUDENT)
                    .build();
            userRepository.save(student);
            log.info("Provisioned demo student account: {}", demoStudentEmail);
        }
    }

    private void seedCourses() {
        if (courseRepository.count() == 0) {
            List<Course> initialCourses = List.of(
                    Course.builder()
                            .title("ICT Fundamentals & Digital Literacy")
                            .slug("ict-fundamentals")
                            .summary("Master essential computing, operating systems, internet safety, and digital workflows.")
                            .description("A comprehensive foundation course for students, professionals, and job seekers looking to gain proficiency in modern computer usage, cloud services, and security practices.")
                            .category("ict")
                            .level(CourseLevel.BEGINNER)
                            .price(150000)
                            .durationWeeks(4)
                            .instructorName("Juma Rashid")
                            .coverGradient("mint")
                            .isPublished(true)
                            .build(),
                    Course.builder()
                            .title("Modern Web Development with React & Next.js")
                            .slug("web-development-react-nextjs")
                            .summary("Build scalable, lightning-fast web applications with modern TypeScript, React, and Next.js.")
                            .description("Learn component-driven design, API integration, state management, and modern CSS architecture with hands-on projects and portfolio building.")
                            .category("web")
                            .level(CourseLevel.INTERMEDIATE)
                            .price(350000)
                            .durationWeeks(8)
                            .instructorName("David Ndosi")
                            .coverGradient("sky")
                            .isPublished(true)
                            .build(),
                    Course.builder()
                            .title("Professional Graphic Design & Branding")
                            .slug("graphic-design-branding")
                            .summary("Master industry-standard visual design tools, typography, composition, and brand identity systems.")
                            .description("Explore color theory, logo construction, print prepress, and social media creative pipelines using Photoshop, Illustrator, and Figma.")
                            .category("design")
                            .level(CourseLevel.BEGINNER)
                            .price(280000)
                            .durationWeeks(6)
                            .instructorName("Neema Kavishe")
                            .coverGradient("peach")
                            .isPublished(true)
                            .build(),
                    Course.builder()
                            .title("Data Analytics & AI Tools for Business")
                            .slug("data-analytics-ai-tools")
                            .summary("Harness practical data analysis, Excel dashboards, SQL, and modern AI automation.")
                            .description("Turn raw business data into actionable visual insights and learn how to leverage generative AI models to accelerate everyday productivity.")
                            .category("data")
                            .level(CourseLevel.INTERMEDIATE)
                            .price(400000)
                            .durationWeeks(6)
                            .instructorName("Emmanuel Lyimo")
                            .coverGradient("lavender")
                            .isPublished(true)
                            .build(),
                    Course.builder()
                            .title("Network Administration & Cybersecurity Essentials")
                            .slug("networking-cybersecurity")
                            .summary("Configure secure local networks, routers, firewalls, and diagnose network connectivity.")
                            .description("Hands-on lab training on IP routing, subnetting, hardware setup, and basic security threat prevention.")
                            .category("networking")
                            .level(CourseLevel.ADVANCED)
                            .price(450000)
                            .durationWeeks(8)
                            .instructorName("Baraka Mushi")
                            .coverGradient("rose")
                            .isPublished(true)
                            .build()
            );

            courseRepository.saveAll(initialCourses);
            log.info("Pre-seeded {} default courses.", initialCourses.size());
        }
    }

    private void seedSampleData() {
        if (labBookingRepository.count() == 0) {
            userRepository.findByEmailIgnoreCase("student@brightfuture.best.com").ifPresent(student -> {
                LabBooking booking = LabBooking.builder()
                        .user(student)
                        .workstationType(WorkstationType.COMPUTER)
                        .bookingDate(LocalDate.now().plusDays(1))
                        .startTime(LocalTime.of(10, 0))
                        .durationHours(2)
                        .status(BookingStatus.CONFIRMED)
                        .notes("Need high-speed internet for web development project submission.")
                        .build();
                labBookingRepository.save(booking);

                PrintOrder order = PrintOrder.builder()
                        .user(student)
                        .serviceType(ServiceType.DOCUMENT)
                        .description("Final Course Project Report (Double-sided)")
                        .copies(15)
                        .color(true)
                        .status(OrderStatus.IN_PROGRESS)
                        .estimatedPrice(4500)
                        .build();
                printOrderRepository.save(order);

                log.info("Pre-seeded sample lab booking and print order for demo student.");
            });
        }
    }
}
