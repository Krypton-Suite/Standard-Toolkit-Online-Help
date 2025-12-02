# Auto-Label Issue Areas Workflow

## Overview

The Auto-Label Issue Areas workflow automatically processes issues to:
1. **Extract area labels** from the "Areas Affected" field in bug reports
2. **Prefix issue titles** based on the issue template type (Bug, Feature Request, Question, etc.)
3. **Apply area labels** to help categorize and route issues to the appropriate maintainers

## Purpose

- **Automated Categorization**: Reduces manual labeling effort
- **Consistent Formatting**: Ensures issue titles follow a standard format
- **Better Organization**: Helps maintainers quickly identify issue scope
- **Template Integration**: Works with GitHub issue form templates

## Trigger Conditions

### Events

- **`issues`** with types:
  - `opened` - When a new issue is created
  - `edited` - When an existing issue is edited (allows re-labeling if areas change)

### Permissions

- `issues: write` - Required to modify issue labels and titles

## Workflow Structure

### Job: `label-areas`

**Runner**: `ubuntu-latest`

**Steps**:

1. **Extract and apply area labels**
   - Uses `actions/github-script@v8` to execute JavaScript
   - Processes issue body and title
   - Extracts area information
   - Applies labels and updates title

## Detailed Behavior

### Title Prefixing Logic

The workflow automatically prefixes issue titles based on template type and labels:

| Template Type | Prefix | Detection Criteria |
|---------------|--------|-------------------|
| Bug Report | `[Bug]: ` | Has `bug` label OR contains "### Steps to Reproduce" |
| Feature Request | `[Feature Request]: ` | Has `enhancement`, `new feature`, or `suggestion` label OR contains "### Feature Description" |
| Other Issues | `[Other Issues]: ` | Has `discussion` or `other` label OR contains "### Please describe your issue" |
| Question | `[Question]: ` | Has `question` label OR contains "### What do you want to ask?" |

**Rules**:
- Only applies to newly opened issues (not edits)
- Skips if title already has the correct prefix
- Applies the first matching template type

### Area Label Mapping

The workflow maps area names from issue forms to GitHub labels:

| Area Name | Label |
|-----------|-------|
| Docking | `area:docking` |
| Navigator | `area:navigator` |
| Ribbon | `area:ribbon` |
| Toolkit | `area:toolkit` |
| Workspace | `area:workspace` |

### Area Extraction Process

1. **Template Detection**: Identifies if the issue is a bug report
2. **Field Extraction**: Searches for "Areas Affected" field using multiple regex patterns
3. **Content Parsing**: Extracts bullet list items or single selections
4. **Validation**: Verifies extracted areas match known area names
5. **Label Application**: Maps areas to labels and applies them

### Regex Patterns

The workflow uses multiple patterns to find the "Areas Affected" field:

```javascript
const patterns = [
  /###\s+Areas Affected\s*\n+([\s\S]*?)(?=\n###|$)/i,
  /###\s+Areas Affected\s*([\s\S]*?)(?=\n###|$)/i,
  /Areas Affected\s*\n+([\s\S]*?)(?=\n###|$)/i,
  /Areas Affected\s*([\s\S]*?)(?=\n###|$)/i
];
```

These patterns handle various markdown formatting differences in GitHub issue forms.

### Empty Field Handling

The workflow skips processing if:
- Field is empty
- Field contains "no selection"
- Field contains "none"
- Field contains "_No response_"

### Label Deduplication

- Checks existing labels before adding new ones
- Only adds labels that aren't already present
- Prevents duplicate labels

## Example Scenarios

### Scenario 1: Bug Report with Single Area

**Issue Body**:
```markdown
### Areas Affected
- Toolkit
```

**Result**:
- Title prefixed: `[Bug]: Original Title`
- Label added: `area:toolkit`

### Scenario 2: Bug Report with Multiple Areas

**Issue Body**:
```markdown
### Areas Affected
- Toolkit
- Ribbon
- Navigator
```

**Result**:
- Labels added: `area:toolkit`, `area:ribbon`, `area:navigator`

### Scenario 3: Feature Request

**Issue Body**:
```markdown
### Feature Description
Add new feature...
```

**Result**:
- Title prefixed: `[Feature Request]: Original Title`
- No area labels (only applies to bug reports)

### Scenario 4: Issue Edit

**Original Issue**: No areas selected
**Edit**: User adds "Areas Affected: Toolkit"

**Result**:
- Label added: `area:toolkit`
- Title not modified (only prefixed on open)

## Error Handling

### Graceful Degradation

- **Title Update Failure**: Logs warning but continues with label processing
- **Label Addition Failure**: Attempts to add labels individually
- **Missing Field**: Logs message and exits gracefully
- **Invalid Area**: Skips unknown areas

### Logging

The workflow provides detailed logging:
- Pattern matching results
- Extracted areas
- Label operations
- Error messages

## Configuration

### No Configuration Required

This workflow requires no secrets, variables, or environment configuration. It uses the default `GITHUB_TOKEN` provided by GitHub Actions.

### Label Requirements

The following labels must exist in the repository:
- `area:docking`
- `area:navigator`
- `area:ribbon`
- `area:toolkit`
- `area:workspace`

If labels don't exist, the workflow will log warnings but continue processing.

## Troubleshooting

### Labels Not Applied

**Possible Causes**:
1. Issue is not a bug report - Area labels only apply to bug reports
2. "Areas Affected" field not found - Check issue body format
3. Labels don't exist - Create missing labels in repository settings
4. Field is empty - This is expected behavior

**Solutions**:
- Verify issue uses bug report template
- Check workflow logs for extraction details
- Ensure labels exist in repository
- Review issue body formatting

### Title Not Prefixed

**Possible Causes**:
1. Issue was edited, not opened - Prefixing only occurs on open
2. Title already has prefix - Workflow skips if prefix exists
3. Template type not detected - Check labels and issue body

**Solutions**:
- Prefix is only added when issue is first opened
- Manually add prefix if needed for existing issues
- Verify issue template is being used correctly

### Multiple Patterns Matched

**Behavior**: The workflow tries patterns in order and uses the first match. This is expected and helps handle various formatting differences.

## Related Workflows

- **Auto-Assign PR Author**: Similar automation pattern for PRs
- **Build Workflow**: May reference labeled issues

## Code Reference

**File**: `.github/workflows/auto-label-issue-areas.yml`

**Key Components**:
- Event: `issues` with types `opened` and `edited`
- Action: `actions/github-script@v8`
- Logic: Regex-based field extraction and label mapping

## Maintenance Notes

### Adding New Areas

To add support for new areas:

1. Add mapping in `areaToLabel` object:
   ```javascript
   'NewArea': 'area:newarea'
   ```

2. Create the label in repository settings: `area:newarea`

3. Update issue template to include the new area option

### Modifying Title Prefixes

To change or add title prefixes:

1. Update the prefix detection logic in the script
2. Modify the `titlePrefix` assignment logic
3. Test with sample issues

### Template Changes

If issue templates change:
- Update regex patterns if field names change
- Adjust detection logic for new template types
- Test extraction with new template format

## Best Practices

1. **Keep Labels Consistent**: Use the `area:*` naming convention
2. **Test Templates**: Verify templates work with the workflow
3. **Monitor Logs**: Check workflow runs for extraction issues
4. **Document Areas**: Keep area list in sync with actual codebase structure

