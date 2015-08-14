# Remove all checkpoints that are older than 14 days
Get-VMCheckpoint -VMMServer VCORPSCVMM01 | ForEach-Object {
	if ($_.AddedTime -lt (Get-Date).AddDays(-14)) {
		Remove-VMCheckpoint -VMCheckpoint $_
	}
}