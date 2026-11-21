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

## Dependencies

- **Dyalog APL**: Version 20.0 or later
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
