# predicate_expression syntax - https://learn.microsoft.com/en-us/sql/t-sql/statements/create-server-audit-transact-sql?view=sql-server-ver16&viewFallbackFrom=azuresqldb-current#syntax
# Set-AzSqlServerAudit - https://learn.microsoft.com/en-us/powershell/module/az.sql/set-azsqlserveraudit
function New-PredicateExpression {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [System.Collections.Hashtable[]]$Conditions
    )

    # Helper function to properly quote values if they are strings
    function Format-QuoteIfNeeded {
        param ([string]$Value)
        if ($Value -match "^\d+(\.\d+)?$") {
            return $Value # Return numbers as-is
        } else {
            return "'" + $Value.Replace("'", "''") + "'" # Single quote and escape single quotes in string values
        }
    }

    $predicate = ""
    # Process each condition in the array
    foreach ($condition in $Conditions) {
        $subPredicate = ""
        if ($condition.ContainsKey("SubConditions")) {
            # Handle grouped subconditions
            foreach ($subCondition in $condition["SubConditions"]) {
                $column = $subCondition["Column"]
                $operator = $subCondition["Operator"]
                $value = $subCondition["Value"]
                $concatenator = if ($subCondition.ContainsKey("Concatenator")) { $subCondition["Concatenator"] } else { "AND" }

                # Build the sub-condition
                $newSubCondition = "$column $operator $(Format-QuoteIfNeeded $value)"
                if (-not [string]::IsNullOrWhiteSpace($subPredicate)) {
                    $subPredicate += " $concatenator $newSubCondition"
                } else {
                    $subPredicate = $newSubCondition
                }
            }
            $subPredicate = "($subPredicate)" # Enclose grouped conditions in parentheses
        } else {
            # Handle simple conditions
            $column = $condition["Column"]
            $operator = $condition["Operator"]
            $value = $condition["Value"]
            $concatenator = if ($condition.ContainsKey("Concatenator")) { $condition["Concatenator"] } else { "AND" }

            $subPredicate = "$column $operator $(Format-QuoteIfNeeded $value)"
        }
        # Append to main predicate with concatenator
        if (-not [string]::IsNullOrWhiteSpace($predicate)) {
            $predicate += " $concatenator $subPredicate"
        } else {
            $predicate = $subPredicate
        }
    }

    return $predicate
}


# Create an array of conditions
$conditions = @(
    # Ignore queries from SSMS IntelliSense
    @{Column="application_name"; Operator="<>"; Value="Microsoft SQL Server Management Studio - Transact-SQL IntelliSense"},
    # Ignore queries from SSMS Object Explorer
    @{Column="statement"; Operator="NOT LIKE"; Value="SELECT SERVERPROPERTY(%"; Concatenator="AND"},
    @{Column="statement"; Operator="<>"; Value="SELECT @@trancount;"; Concatenator="AND"},
    @{Column="statement"; Operator="<>"; Value="SELECT @@SPID;"; Concatenator="AND"},
    
    # Only BATCH COMPLETED queries that return rows
    # BCM - https://sqlquantumleap.com/reference/server-audit-filter-values-for-action_id/
    @{
       SubConditions = @(
            @{Column="action_id"; Operator="="; Value="BCM"},
            @{Column="affected_rows"; Operator=">"; Value="0"; Concatenator="AND"}
        )
        Concatenator="AND"
    }
)

# Generate the predicate expression
$predicate = New-PredicateExpression -Conditions $conditions

# Print the final predicate
Write-Host "[$($predicate.Length)] Final Predicate Expression: $predicate"
