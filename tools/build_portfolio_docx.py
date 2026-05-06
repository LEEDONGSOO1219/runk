from __future__ import annotations

from pathlib import Path

from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.table import WD_ALIGN_VERTICAL, WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt, RGBColor


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "deliverables"
OUT_PATH = OUT_DIR / "Runk_Portfolio_Report.docx"

NAVY = RGBColor(31, 56, 100)
GREEN = RGBColor(30, 122, 91)
LIGHT_BLUE = "D9EAF7"
LIGHT_GREEN = "E2F0D9"
LIGHT_GRAY = "F2F2F2"
WHITE = "FFFFFF"


def set_cell_shading(cell, fill: str) -> None:
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = tc_pr.find(qn("w:shd"))
    if shd is None:
        shd = OxmlElement("w:shd")
        tc_pr.append(shd)
    shd.set(qn("w:fill"), fill)


def set_cell_text(cell, text: str, bold: bool = False, color: RGBColor | None = None) -> None:
    cell.text = ""
    paragraph = cell.paragraphs[0]
    paragraph.alignment = WD_ALIGN_PARAGRAPH.LEFT
    run = paragraph.add_run(text)
    run.bold = bold
    run.font.name = "Malgun Gothic"
    run._element.rPr.rFonts.set(qn("w:eastAsia"), "Malgun Gothic")
    run.font.size = Pt(9)
    if color:
        run.font.color.rgb = color
    cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER


def set_table_borders(table) -> None:
    tbl = table._tbl
    tbl_pr = tbl.tblPr
    borders = tbl_pr.first_child_found_in("w:tblBorders")
    if borders is None:
        borders = OxmlElement("w:tblBorders")
        tbl_pr.append(borders)
    for edge in ("top", "left", "bottom", "right", "insideH", "insideV"):
        tag = "w:{}".format(edge)
        element = borders.find(qn(tag))
        if element is None:
            element = OxmlElement(tag)
            borders.append(element)
        element.set(qn("w:val"), "single")
        element.set(qn("w:sz"), "4")
        element.set(qn("w:space"), "0")
        element.set(qn("w:color"), "D9D9D9")


def set_repeat_table_header(row) -> None:
    tr_pr = row._tr.get_or_add_trPr()
    tbl_header = OxmlElement("w:tblHeader")
    tbl_header.set(qn("w:val"), "true")
    tr_pr.append(tbl_header)


def add_table(doc: Document, headers: list[str], rows: list[list[str]], widths: list[float] | None = None):
    table = doc.add_table(rows=1, cols=len(headers))
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.style = "Table Grid"
    set_table_borders(table)
    hdr = table.rows[0]
    set_repeat_table_header(hdr)
    for idx, header in enumerate(headers):
        set_cell_shading(hdr.cells[idx], LIGHT_BLUE)
        set_cell_text(hdr.cells[idx], header, bold=True, color=NAVY)
        hdr.cells[idx].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
    for row in rows:
        cells = table.add_row().cells
        for idx, value in enumerate(row):
            set_cell_text(cells[idx], value)
            if len(value) <= 8:
                cells[idx].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
    if widths:
        for row in table.rows:
            for idx, width in enumerate(widths):
                row.cells[idx].width = Cm(width)
    doc.add_paragraph()
    return table


def add_callout(doc: Document, title: str, body: str, fill: str = LIGHT_GREEN) -> None:
    table = doc.add_table(rows=1, cols=1)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    cell = table.cell(0, 0)
    set_cell_shading(cell, fill)
    p = cell.paragraphs[0]
    p.paragraph_format.space_after = Pt(4)
    r = p.add_run(title)
    r.bold = True
    r.font.name = "Malgun Gothic"
    r._element.rPr.rFonts.set(qn("w:eastAsia"), "Malgun Gothic")
    r.font.size = Pt(10)
    r.font.color.rgb = NAVY
    p2 = cell.add_paragraph(body)
    p2.paragraph_format.space_after = Pt(0)
    for run in p2.runs:
        run.font.name = "Malgun Gothic"
        run._element.rPr.rFonts.set(qn("w:eastAsia"), "Malgun Gothic")
        run.font.size = Pt(9)
    doc.add_paragraph()


def add_bullets(doc: Document, items: list[str]) -> None:
    for item in items:
        p = doc.add_paragraph(style="List Bullet")
        p.add_run(item)


def add_heading(doc: Document, text: str, level: int = 1) -> None:
    p = doc.add_heading(text, level=level)
    for run in p.runs:
        run.font.name = "Malgun Gothic"
        run._element.rPr.rFonts.set(qn("w:eastAsia"), "Malgun Gothic")
        run.font.color.rgb = NAVY if level == 1 else GREEN


def add_paragraph(doc: Document, text: str = "") -> None:
    p = doc.add_paragraph(text)
    p.paragraph_format.space_after = Pt(6)


def configure_styles(doc: Document) -> None:
    styles = doc.styles
    normal = styles["Normal"]
    normal.font.name = "Malgun Gothic"
    normal._element.rPr.rFonts.set(qn("w:eastAsia"), "Malgun Gothic")
    normal.font.size = Pt(10)

    for style_name, size, color in [
        ("Title", 26, NAVY),
        ("Heading 1", 17, NAVY),
        ("Heading 2", 13, GREEN),
        ("Heading 3", 11, NAVY),
    ]:
        style = styles[style_name]
        style.font.name = "Malgun Gothic"
        style._element.rPr.rFonts.set(qn("w:eastAsia"), "Malgun Gothic")
        style.font.size = Pt(size)
        style.font.color.rgb = color


def setup_page(doc: Document) -> None:
    section = doc.sections[0]
    section.top_margin = Cm(1.8)
    section.bottom_margin = Cm(1.8)
    section.left_margin = Cm(1.8)
    section.right_margin = Cm(1.8)
    section.header_distance = Cm(1.0)
    section.footer_distance = Cm(1.0)


def add_footer(section, text: str) -> None:
    footer = section.footer
    p = footer.paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    p.text = text
    for run in p.runs:
        run.font.name = "Malgun Gothic"
        run._element.rPr.rFonts.set(qn("w:eastAsia"), "Malgun Gothic")
        run.font.size = Pt(8)
        run.font.color.rgb = RGBColor(100, 100, 100)


def build_doc() -> None:
    OUT_DIR.mkdir(exist_ok=True)
    doc = Document()
    setup_page(doc)
    configure_styles(doc)
    add_footer(doc.sections[0], "Runk Portfolio Report")

    # Cover
    title = doc.add_paragraph()
    title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    title.paragraph_format.space_before = Pt(70)
    run = title.add_run("런크(Runk)\n포트폴리오 보고서")
    run.bold = True
    run.font.name = "Malgun Gothic"
    run._element.rPr.rFonts.set(qn("w:eastAsia"), "Malgun Gothic")
    run.font.size = Pt(28)
    run.font.color.rgb = NAVY

    subtitle = doc.add_paragraph()
    subtitle.alignment = WD_ALIGN_PARAGRAPH.CENTER
    subtitle.paragraph_format.space_before = Pt(18)
    sub = subtitle.add_run("러닝 기록 기반 소셜 네트워크 서비스 MVP")
    sub.font.name = "Malgun Gothic"
    sub._element.rPr.rFonts.set(qn("w:eastAsia"), "Malgun Gothic")
    sub.font.size = Pt(14)
    sub.font.color.rgb = GREEN

    doc.add_paragraph()
    add_table(
        doc,
        ["항목", "내용"],
        [
            ["프로젝트 유형", "1인 개발 MVP"],
            ["기술 스택", "Flutter, FastAPI, MySQL, Docker Compose"],
            ["현재 단계", "1단계 MVP 기본 구현 및 개발환경 구축 완료"],
            ["Repository", "Private GitHub repository: LEEDONGSOO1219/runk"],
        ],
        [4, 11],
    )
    add_callout(
        doc,
        "핵심 요약",
        "회원가입, 로그인, 러닝 기록 저장, 피드 조회, 프로필 확인까지 이어지는 MVP 핵심 흐름을 구현하고 백엔드 smoke test와 Flutter analyze/test를 통과했습니다.",
    )
    doc.add_page_break()

    # Contents
    add_heading(doc, "목차", 1)
    for idx, item in enumerate(
        [
            "프로젝트 개요",
            "요구사항 정의",
            "WBS",
            "시스템 아키텍처",
            "API 명세",
            "DB 설계",
            "테스트 계획 및 결과",
            "개발 회고 및 향후 계획",
        ],
        start=1,
    ):
        add_paragraph(doc, f"{idx}. {item}")
    doc.add_page_break()

    add_heading(doc, "1. 프로젝트 개요", 1)
    add_paragraph(
        doc,
        "런크(Runk)는 러닝 기록을 기반으로 러너들이 서로의 활동을 확인하고 동기부여를 받을 수 있는 러닝 소셜 네트워크 서비스입니다.",
    )
    add_table(
        doc,
        ["구분", "내용"],
        [
            ["프로젝트명", "런크(Runk)"],
            ["개발 형태", "1인 개발 프로젝트"],
            ["목표 사용자", "초보 러너, 개인 러너, 기록 공유를 원하는 사용자"],
            ["MVP 목표", "회원가입 -> 기록 저장 -> 피드 조회까지 이어지는 핵심 흐름 검증"],
        ],
        [4, 11],
    )
    add_heading(doc, "기능 범위", 2)
    add_table(
        doc,
        ["단계", "포함 기능"],
        [
            ["1단계 MVP", "회원가입/로그인, 러닝 기록 저장, 피드, 프로필"],
            ["2단계", "친구 기능, 랭킹"],
            ["3단계", "GPS 좌표 저장, 룰 기반 AI 피드, 러닝 코스 추천"],
        ],
        [4, 11],
    )

    add_heading(doc, "2. 요구사항 정의", 1)
    add_heading(doc, "기능 요구사항", 2)
    add_table(
        doc,
        ["ID", "요구사항", "우선순위", "MVP"],
        [
            ["FR-001", "이메일, 닉네임, 비밀번호로 회원가입할 수 있다.", "높음", "포함"],
            ["FR-002", "이메일과 비밀번호로 로그인할 수 있다.", "높음", "포함"],
            ["FR-003", "사용자는 자신의 프로필 정보를 조회할 수 있다.", "높음", "포함"],
            ["FR-004", "거리, 시간, 날짜, 메모로 러닝 기록을 저장할 수 있다.", "높음", "포함"],
            ["FR-005", "시스템은 거리와 시간을 기반으로 페이스를 계산한다.", "높음", "포함"],
            ["FR-006", "사용자는 최신 러닝 기록 피드를 조회할 수 있다.", "높음", "포함"],
            ["FR-007", "친구 추가와 주간 랭킹을 제공한다.", "중간", "제외"],
            ["FR-008", "GPS 좌표 저장과 코스 추천을 제공한다.", "낮음", "제외"],
        ],
        [2.2, 8.2, 2.2, 2.0],
    )
    add_heading(doc, "비기능 요구사항", 2)
    add_table(
        doc,
        ["ID", "구분", "요구사항"],
        [
            ["NFR-001", "보안", "비밀번호는 평문으로 저장하지 않는다."],
            ["NFR-002", "보안", "인증 API는 JWT Bearer token을 사용한다."],
            ["NFR-003", "유지보수", "요청/응답 구조는 Pydantic Schema로 분리한다."],
            ["NFR-004", "실행환경", "개발용 DB는 Docker Compose로 실행 가능해야 한다."],
            ["NFR-005", "문서화", "로컬 실행 방법과 API 구조를 문서화한다."],
        ],
        [2.4, 3.0, 9.6],
    )

    add_heading(doc, "3. WBS", 1)
    add_table(
        doc,
        ["WBS", "작업", "산출물", "상태"],
        [
            ["1", "프로젝트 기획", "프로젝트 개요, 요구사항 정의서", "완료"],
            ["2", "개발환경 구축", "Python, Docker, Flutter, Android 구조", "완료"],
            ["3", "백엔드 MVP 구현", "FastAPI API, MySQL 연동", "완료"],
            ["4", "프론트엔드 MVP 구현", "Flutter 화면, API 클라이언트", "완료"],
            ["5", "검증", "Backend smoke test, Flutter analyze/test", "완료"],
            ["6", "문서화", "README, 개발문서, 포트폴리오 문서", "완료"],
            ["7", "GitHub 업로드", "Private repository", "완료"],
            ["8", "Android 검증", "Emulator 앱 실행 확인", "예정"],
        ],
        [2.0, 5.0, 6.0, 2.2],
    )
    add_heading(doc, "마일스톤", 2)
    add_table(
        doc,
        ["마일스톤", "목표", "상태"],
        [
            ["M1", "MVP 기능 범위 확정", "완료"],
            ["M2", "백엔드/DB 실행 성공", "완료"],
            ["M3", "Flutter 기본 화면 구현", "완료"],
            ["M4", "GitHub private 업로드", "완료"],
            ["M5", "Android Emulator 검증", "예정"],
        ],
        [3.0, 9.0, 2.4],
    )

    add_heading(doc, "4. 시스템 아키텍처", 1)
    add_callout(
        doc,
        "Architecture",
        "Flutter App -> REST API -> FastAPI Backend -> SQLAlchemy ORM -> MySQL Database",
        LIGHT_BLUE,
    )
    add_table(
        doc,
        ["구성 요소", "역할"],
        [
            ["Flutter App", "사용자 화면, 입력 처리, API 호출"],
            ["FastAPI Backend", "인증, 러닝 기록 저장, 피드 조회 API 제공"],
            ["MySQL", "사용자 정보와 러닝 기록 저장"],
            ["Docker Compose", "개발용 MySQL 컨테이너 실행"],
            ["Android Studio", "Android 앱 실행 및 에뮬레이터 관리"],
        ],
        [4, 11],
    )
    add_heading(doc, "인증 흐름", 2)
    add_bullets(
        doc,
        [
            "회원가입 또는 로그인 요청을 FastAPI 서버로 전송한다.",
            "서버는 사용자 정보를 검증하고 JWT access token을 발급한다.",
            "Flutter 앱은 인증 API 호출 시 Authorization header에 Bearer token을 포함한다.",
        ],
    )

    add_heading(doc, "5. API 명세", 1)
    add_table(
        doc,
        ["Method", "Endpoint", "설명", "인증"],
        [
            ["GET", "/health", "서버 상태 확인", "불필요"],
            ["POST", "/auth/signup", "회원가입", "불필요"],
            ["POST", "/auth/login", "로그인", "불필요"],
            ["GET", "/users/me", "내 프로필 조회", "필요"],
            ["POST", "/running-records", "러닝 기록 저장", "필요"],
            ["GET", "/running-records/me", "내 러닝 기록 조회", "필요"],
            ["GET", "/feed", "최신 피드 조회", "불필요"],
        ],
        [2.3, 4.5, 5.7, 2.0],
    )
    add_heading(doc, "러닝 기록 저장 예시", 2)
    add_callout(
        doc,
        "POST /running-records",
        '{ "distance_km": 5.0, "duration_seconds": 1800, "run_date": "2026-05-06", "memo": "5km easy run" }',
        LIGHT_GRAY,
    )

    add_heading(doc, "6. DB 설계", 1)
    add_callout(doc, "ERD", "users 1 ─── N running_records", LIGHT_BLUE)
    add_heading(doc, "users 테이블", 2)
    add_table(
        doc,
        ["컬럼", "타입", "설명"],
        [
            ["id", "Integer / PK", "사용자 ID"],
            ["email", "String(255)", "로그인 이메일, Unique"],
            ["username", "String(50)", "닉네임, Unique"],
            ["hashed_password", "String(255)", "해시된 비밀번호"],
            ["created_at", "DateTime", "가입 시각"],
        ],
        [4, 4, 7],
    )
    add_heading(doc, "running_records 테이블", 2)
    add_table(
        doc,
        ["컬럼", "타입", "설명"],
        [
            ["id", "Integer / PK", "러닝 기록 ID"],
            ["user_id", "Integer / FK", "작성자 ID"],
            ["distance_km", "Float", "거리(km)"],
            ["duration_seconds", "Integer", "러닝 시간(초)"],
            ["pace_seconds_per_km", "Integer", "1km당 페이스"],
            ["run_date", "Date", "러닝 날짜"],
            ["memo", "String(255)", "메모"],
            ["created_at", "DateTime", "생성 시각"],
        ],
        [4, 4, 7],
    )

    add_heading(doc, "7. 테스트 계획 및 결과", 1)
    add_table(
        doc,
        ["ID", "테스트 항목", "기대 결과", "결과"],
        [
            ["TC-BE-001", "/health 호출", "status ok 반환", "통과"],
            ["TC-BE-002", "회원가입", "access token 반환", "통과"],
            ["TC-BE-003", "러닝 기록 저장", "기록 ID 반환", "통과"],
            ["TC-BE-004", "피드 조회", "저장된 기록 포함", "통과"],
            ["TC-FE-001", "Flutter analyze", "No issues found", "통과"],
            ["TC-FE-002", "Flutter widget test", "All tests passed", "통과"],
        ],
        [2.5, 5.0, 5.0, 2.0],
    )
    add_heading(doc, "미수행 테스트", 2)
    add_bullets(
        doc,
        [
            "Android Emulator에서 실제 회원가입 -> 기록 저장 -> 피드 조회 플로우 검증",
            "네트워크 오류 및 입력값 경계 테스트",
            "친구/랭킹 기능 테스트는 2단계에서 수행",
        ],
    )

    add_heading(doc, "8. 개발 회고 및 향후 계획", 1)
    add_heading(doc, "잘한 점", 2)
    add_bullets(
        doc,
        [
            "MVP 범위를 명확히 제한해 핵심 흐름을 먼저 완성했다.",
            "Docker, FastAPI, Flutter 실행 과정을 스크립트와 문서로 정리했다.",
            "회원가입, 기록 저장, 피드 조회를 smoke test로 검증했다.",
            "passlib와 bcrypt 버전 호환 문제를 발견하고 고정했다.",
        ],
    )
    add_heading(doc, "개선할 점", 2)
    add_bullets(
        doc,
        [
            "Android Emulator에서 실제 앱 실행 캡처를 추가한다.",
            "UI를 포트폴리오 제출용으로 더 정돈한다.",
            "오류 응답과 입력 검증 메시지를 강화한다.",
            "Alembic을 도입해 DB 마이그레이션을 관리한다.",
        ],
    )
    add_heading(doc, "다음 개발 계획", 2)
    add_table(
        doc,
        ["순서", "작업"],
        [
            ["1", "Android Studio에서 앱 실행"],
            ["2", "회원가입부터 피드 조회까지 앱 수동 테스트"],
            ["3", "UI polish"],
            ["4", "친구 기능 설계"],
            ["5", "주간 랭킹 API 구현"],
        ],
        [2, 13],
    )

    doc.save(OUT_PATH)


if __name__ == "__main__":
    build_doc()
