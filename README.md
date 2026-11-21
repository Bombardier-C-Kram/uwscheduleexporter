# UW Schedule Exporter

A web-based application built in Dyalog APL that converts University of Waterloo Quest class schedules into iCalendar (.ics) format for import into calendar applications.

## Quick Start

1. **Start the Server**:
   ```apl
   start
   ```
   This starts a web server on `http://localhost:8080`

2. **Access the Web Interface**:
   Open your browser and navigate to `http://localhost:8080`

3. **Export Your Schedule**:
   - Login to [UW Quest](https://quest.pecs.uwaterloo.ca/psp/SS/?cmd=login)
   - Navigate to your Class Schedule
   - Select all content (Ctrl+A) and copy (Ctrl+C)
   - Paste into the web form
   - Customize templates if desired
   - Click "Process Schedule" to download your .ics file

## Project Structure

```
uwscheduleexporter/
├── APLSource/
│   ├── web.apln      # Web interface
│   ├── start.aplf    # Server startup function
│   ├── uwsch.aplf    # UW Quest schedule parser
│   ├── ical.aplf     # iCalendar format generator
│   └── save.aplf     # File saving utility
├── deps/             # Dependencies (Jarvis web server)
├── cider.config      # Cider project configuration
└── README.md         # This file
```

## Functions Reference

### Core Functions

#### `start`
Initializes and starts the Jarvis web server on port 8080.
- **Global Variables Created**: `JSrv` (server instance)
- **Usage**: `start`

#### `uwsch schedule`
Parses raw UW Quest schedule text into structured data.
- **Args**: `schedule` - Character vector of schedule text
- **Returns**: Vector of course namespaces with class details
- **Usage**: `courses ← uwsch scheduleText`

#### `summary description ical courses`
Generates iCalendar format from structured course data.
- **Left Args**: Two-element vector `[summary, description]` with template strings
- **Right Arg**: `courses` - Vector of course namespaces from `uwsch`
- **Returns**: Complete iCalendar file content
- **Usage**: `icalContent ← ('Event Title' 'Event Description') ical courses`

#### `save content`
Saves content to 'uwclasses.ics' file. For debug/local purposes.
- **Args**: `content` - Character vector to save
- **Usage**: `save icalContent`

### Web Interface Functions

#### `web.Index req`
HTTP GET handler for the main application page.
- **Args**: `req` - HTTP request object
- **Returns**: HTML content for the web interface

#### `req web.ProcessSchedule`
HTTP POST handler for processing schedule data.
- **Args**: `req` - HTTP request with JSON payload
- **Returns**: iCalendar file content with download headers

## Template Variables

The following variables can be used in summary and description templates:

| Variable | Description | Example |
|----------|-------------|---------|
| `@code` | Course code | `ECE 150` |
| `@section` | Section identifier | `001` |
| `@name` | Course name | `Fundamentals of Programming` |
| `@type` | Component type | `LEC`, `LAB`, `TUT` |
| `@location` | Room location | `DC 1350` |
| `@prof` | Instructor name | `Smith, John` |

### Default Templates

- **Summary**: `@code @type in @location`
- **Description**: `@code-@section: @name (@type) in @location with @prof`

## Data Structures

### Course Namespace
```apl
course.(
    code: ''        ⍝ Course code (e.g., 'ECE 150')
    name: ''        ⍝ Course title
    status: ''      ⍝ Enrollment status
    units: 0        ⍝ Credit units
    grading: ''     ⍝ Grading scheme
    classes: ⍬      ⍝ Vector of class namespaces
)
```

### Class Namespace
```apl
class.(
    number: 0       ⍝ Class number
    section: ''     ⍝ Section identifier
    component: ''   ⍝ Component type (LEC, LAB, TUT, etc.)
    days: ''        ⍝ Days of week (e.g., 'MWF')
    starttime: ''   ⍝ Start time (e.g., '08:30')
    endtime: ''     ⍝ End time (e.g., '09:20')
    room: ''        ⍝ Room location
    instructor: ''  ⍝ Instructor name
    start: ''       ⍝ Start date
    end: ''         ⍝ End date
)
```

## Testing

```bash
./test.apls            # from the repository root; exit code 0 if everything passed
```

or `testuwsch` / `Tests.Run` in a session. The suite (`APLSource/Tests/`, one function per file; start at `Run.aplf`) runs:

- **Unit tests** for `detectDateFormat` and `ical` on a hand-built course.
- **Expected-output tests**: each fixture in `tests/fixtures/` has the expected parse (`.json`) and the expected
  class meetings (`.events`, one line per meeting: date, time, summary, description). The calendar is expanded
  into meetings before comparing, so it is checked for what it means, not how it is formatted.
- **RFC 5545 checks**: CRLF line endings, line folding, UID/DTSTAMP, VTIMEZONE, UTC `UNTIL`, escaped text.
- **Variants**: each fixture is rewritten with LF/CRLF/CR line endings, DD/MM↔MM/DD dates, 12h↔24h times, empty lines removed, and junk around it. Every variant must give the same calendar.
- **Privacy guard**: fails if a fixture names anyone other than the fake student and fake instructors.
- Any raw pastes in `tests/*.txt` (gitignored) are compared with the reference model and run through the variants.

Expected files are **never generated from the code under test**. They come from a separate, deliberately plain
reference model in `APLSource/Tests/` (`RefParse`, `RefEvents`), so a bug in `uwsch` or `ical` makes a test fail
instead of becoming the expected output. Tests for known bugs stay red until the bug is fixed.

### Adding a schedule

Real Quest pastes contain the student's and instructors' names, so they must never be committed.
Save the paste as `tests/<anything>.txt` (ignored by git), then in a session at the repository root:

```apl
Tests.Anonymise 'tests/<anything>.txt'
```

This writes `tests/fixtures/<term>-<ddmm|mmdd>-<12h|24h>-<lf|crlf|cr>-<plain|tabbed>.txt` plus its `.json` and `.events`.
Names are replaced with same-length fakes; everything else is kept byte for byte. Nothing is written unless
no name (or part of one) remains, swapping the names back restores the original exactly, the parse is
unchanged, and there is no unrecognised text (which could be personal data such as a student number).
If it stops on text you have checked is harmless, allow it explicitly: `'message.txt' '8 Ko' Tests.Anonymise '...'`.

`Tests.WriteExpected ''` rewrites the expected files from the reference model (e.g. after changing the
templates or fixing the model). Review `git diff tests/fixtures`: these files are the specification.
If the app's output changes on purpose, change the reference model, not the expected files by hand.

## Dependencies

- **Dyalog APL**: Version 21.0 or later (the tests use `⎕DT` pattern parsing, new in 21.0)
- **Jarvis**: Web server framework (included in `deps/`)
- **Cider/Tatin**: APL project/package manager

## Calendar Import

The generated .ics files are compatible with:
- Google Calendar
- Microsoft Outlook
- Apple Calendar
- Mozilla Thunderbird
- Most calendar applications supporting iCalendar format

## License

This project is licensed under the MIT license. See `LICENSE.txt` for license information.
