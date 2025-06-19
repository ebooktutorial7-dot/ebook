// 🔹 최상단: plugins 블록
plugins {
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.10" apply false
    id("com.google.gms.google-services") version "4.4.0" apply false // ✅ Firebase용
}

// 🔹 프로젝트 전역 설정 (필요시)
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

// 🔹 루트 프로젝트 이름
rootProject.name = "ebook_tutorial_app"

// (옵션) 포함할 모듈
include(":app")
